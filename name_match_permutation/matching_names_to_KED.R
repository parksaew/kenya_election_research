

### Matching petitioner and respondents to candidate data ######################################

#set-up
pacman:: p_load(RODBC,
                stringr,
                tidyverse,
                RQDA,
                gtools,
                reshape2)
RQDA
openProject("C:/Users/Spark/Dropbox/kenya_court_petitions/kenya_kp_rqda.rqda", updateGUI = TRUE)


### 1. Import and check Kenya Election Database ###############################################

# The KED data is in an *.mdb file, need to use SQL arguments
# A guide on handling *.mdb in R: https://www.r-bloggers.com/getting-access-data-into-r/
#I have to change R to 32 bit in global settings for odbcConnectAccess() to work


#opening a connection with the mdb file
conn_ked <- odbcConnectAccess("C:/Users/Spark/Dropbox/kenya_court_petitions/data_raw/KED_data/KENYA ELECTION DATABASE-VER.1.0.03.13.mdb",
                       pwd = "ked622k")

#list of all the tales in KED
ked_sqltable <- sqlTables(conn_ked)

#head(sqlColumns(conn_ked, "tblCONSTITUENCY")) 
#this shows the structure of the columns in a specific table

#extracting and saving county information for later use
county <- sqlQuery(conn_ked, "SELECT * FROM tblCOUNTIES")
write.csv(county, file = "C:/Users/Spark/Dropbox/kenya_court_petitions/data_clean/county_info.csv")


#SQL terminology - view vs table: 
 #A database view is a searchable object in a database that is defined by a query. AKA "virtual tables"
 #Though a view doesn't store data, you can query a view like you can a table using SQL. 
 #A view can combine data from two or more tables, using joins, and also just contain a subset of information.




### 2. Extracting data from KED to match with petitioner/respondent data ###################################### 

#We need to get:
  #1. Party affiliations of candidates (petitioner and respondent)
  #2. Pre-election status of candidates (petitioner and respondent)

#parliamentary candidate info
cand_info_par <- sqlQuery(conn_ked, 'SELECT * FROM "CAND RESULTS 2013 PAR ELEC BY PARTY-ALL Query"')

#for county level elections we need to add an NA vector for the constituency code in order to do union operations

#governor candidate info
cand_info_gov <- sqlQuery(conn_ked, 'SELECT * FROM "CAND RESULTS 2013 GOV ELEC BY PARTY-ALL Query"') %>%
  mutate(`ConstCode-2012` = as.integer(NA))

#senator candidate info
cand_info_sen <- sqlQuery(conn_ked, 'SELECT * FROM "CAND RESULTS 2013 SEN ELEC BY PARTY-ALL Query"') %>%
  mutate(`ConstCode-2012` = as.integer(NA))

#women rep candidate info
#Here, gender is set to FALSE and it needs to changed into "F" for female
cand_info_wom <- sqlQuery(conn_ked, 'SELECT * FROM "CAND RESULTS 2013 WOMEN REP ELEC BY PARTY-ALL Query"') %>%
  mutate(`ConstCode-2012` = as.integer(NA), Gender = as.factor("F"))


#columns needed: PartyCode , PartyName , CandStatus (incumbent, former candidate, former winner, newcomer)
  #but keep the other columns too in case they are needed

#merging all election types
cand_info_all <- bind_rows(cand_info_par, cand_info_gov, cand_info_sen, cand_info_wom) %>%
  mutate(ElecType = as.factor(ElecType), 
         CandRank = as.factor(CandRank),
         Gender = as.factor(Gender),
         PartyCode = as.factor(PartyCode),
         PartyName = as.factor(PartyName),
         CandStatus = as.factor(CandStatus))

write.csv(cand_info_all, file = "C:/Users/Spark/Dropbox/kenya_court_petitions/data_clean/candidate_info.csv")

close(conn_ked) 




### 3. Matching KED to petitioner and respondent names ###########################################################

#list of file names in RQDA
file_names <- RQDAQuery("SELECT name, id 
                        FROM source")

#file attributes from RQDA - includes petitioner and respondent names
file_attributes <- RQDAQuery("SELECT fileID, variable, value
                             FROM fileAttr") %>%
  distinct() %>%
  spread(variable, value) %>%
  filter(fileID %in% file_names$id) #remove files that are no longer active

###

#In Kenya, name order (first, middle, last names) are often mixed up. 
#Matching just the first and last name pairs as recorded in data would result in a lot of true negatives.
#Therefore, when matching names of two lists, the all permutations of the different names have to be used.


### Permutations of the KED names ###

#KED data has the full names
#What is the longest number of names a person can have?
names_max_length <- max(lengths(strsplit(as.character(cand_info_all$CandName), " ")))
# P(6,2) = 30, so 30 permutations of the names are needed

#split the full names into single names in order to get all the permulations
candname_split <- as.data.frame(cbind(as.character(cand_info_all$CandRank), 
                                      as.character(cand_info_all$CandName), 
                                      str_split_fixed(as.character(cand_info_all$CandName), 
                                                      " ", 
                                                      names_max_length))) %>%
  mutate_all(as.character)

names(candname_split) <- c("candrank_key",
                           "candname", #fullname
                           "name1", 
                           "name2",
                           "name3",
                           "name4",
                           "name5",
                           "name6")


#a function for the permutations of name pairs
permute_paste <- function(x, sample){
  leng <- length(x)
  result <- apply(permutations(leng, sample, as.character(x), set = F, repeats.allowed = F), 
                  1,
                  paste,
                  collapse = " ")
  return(result)
}
#x is the maximum number of single names that a full name can have
#sample is how many names are being picked from it


#apply this function to the candidate name dataframe to get all the possible pairs of names
#and merge it with the candidate key and full name
#each row is one candidate
candname_perm <- as.data.frame(cbind(as.character(cand_info_all$CandRank), 
                                     as.character(cand_info_all$CandName), 
                                     t(apply(candname_split[,3:8], 
                                             1, 
                                             permute_paste, 
                                             sample = 2)))) %>%
  mutate_all(as.character) %>%
  dplyr::rename("candrank" = "V1", "candname" = "V2")

colnames(candname_perm)[3:32] <- paste0("combination", 1:30)

#now we are ready to match these names to the petitioner/respondent names (which only have first and last names)


### Matching KED naems to RQDA names using grepl/agrep ###

#petitioner names from RQDA
petitioner <- filter(file_attributes, petitioner_candidate == "yes") %>%
  select(fileID, 
         petitioner_first_name, 
         petitioner_last_name, 
         unit_code, 
         unit_name,
         position) %>%
  mutate(fullname = paste(petitioner_first_name, petitioner_last_name, sep = " "))


#made a new agrep function so that the target (vector where the matches are sought- "combinations") will be the main input
my_agrep <- function(combinations, source, max){
  list <- sapply(source,
                 agrep,
                 x = combinations,
                 value = T, 
                 ignore.case = T,
                 max = max)
  result <- melt(list)  
  result[,1] <- as.character(result[,1])
  return(result)
}


#apply this over all the combinations 
fuzzy_name_match <- apply(candname_perm[,3:32], 
                         2, 
                         my_agrep, 
                         source = petitioner$fullname, 
                         max = 0.05)

#now we have matches between KED names and RQDA petitioner names




#create one list of all the names

#first create a df of all possible name matches (name-name is a unit)
#bind all the rows together

all_name_matches <- bind_rows(fuzzy_name_match)


#bind district info from KED and RQDA
###****####

#RQDA info
all_name_matches <- bind_rows(fuzzy_name_match) %>%
  left_join(select(petitioner,
                   fileID,
                   fullname, 
                   unit_code, 
                   unit_name,
                   position), 
            by = c("L1" = "fullname")) %>%
  mutate(unit_code_county = ifelse(position != "MP", unit_code, NA),
         unit_code_constituency = ifelse(position == "MP", unit_code, NA))


#KED info
candname_perm2 <- left_join(candname_perm, 
                            select(cand_info_all, 
                                   CandRank, 
                                   ConstCode.2012, 
                                   CountyCode, 
                                   CountyName,
                                   ElecType),
                            by = c("candrank" = "CandRank")) 

candname_perm2 <- gather(candname_perm2, "erase", "ked_fullname", contains("combination"))


all_matches2 <- left_join(all_matches, candname_perm2, by = c("value" = "ked_fullname")) %>%
  mutate(erase = NULL, 
         ElecType = case_when(ElecType == "PARLIAMENTARY" ~ "MP",
                              ElecType == "GUBERNATORIAL" ~ "governor",
                              ElecType == "SENATORIAL" ~ "senator",
                              ElecType == "WOMEN REP" ~ "women_rep"),
         unit_code_constituency = as.integer(unit_code_constituency),
         unit_code_county = as.integer(unit_code_county),
         CountyCode_only = case_when(ElecType != "MP" ~ CountyCode)) %>%
  filter(ElecType == position & 
           (unit_code_constituency == ConstCode.2012 |
              is.na(unit_code_constituency) |
              is.na(ConstCode.2012)) &
           (unit_code_county == CountyCode_only |
              is.na(unit_code_county) | 
              is.na(CountyCode_only))) %>%
  distinct()



#DONE with matching

write.csv(all_matches2, "C:/Users/Spark/Dropbox/kenya_court_petitions/code/all_matches.csv")




##### note: embakasi east code should be 284 for mary mwangi and there is a "govenor" typo in the data #####
# 59 out of 71 candidate petitioners were matched in the KED dataset
```

