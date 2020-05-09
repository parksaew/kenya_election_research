Matching names: Example using Kenya Election Database (KED) and RQDA
data on Kenyan election petitions
================
SaewonPark
August 17, 2018

## The Issue

There can be multiple datasets on the same set of people, where the only
common variable is the names of the people. For names that follow the
convention of first and last names, in that order, joining two datasets
using the names as the key is easily done. However, there are many
countries where the ordering of a person’s names is not strictly
conserved from one public record to another. The following codes explore
different ways to match names with “mixed”
orders.

### 1\. Create two datasets containing information on the same set of people

I came across this problem when using data from Kenya because Kenyans
use their first, middle, and last names interchangeably. Therefore, I
will be working with a sample of the original dataset I used for my
research. However, the following methods should be applicable to any
case where the order of names are mixed up.

Data sources: 1. Kenya Election Database
(<https://kenyaelectiondatabase.co.ke/?m=2013>)

2.  Kenya Law website - section on elections petitions
    (<http://kenyalaw.org/kl/index.php?id=4161>)

The common variable in these two datasets are the names of the
candidates who ran for office in 2013 (recorded as “petitioners” in the
election petition dataset). In the Kenya Election Database (KED), the
full names of candidates are recorded while the election petitions
database records only the first and last names of losing candidates that
chose to petition the election results. The goal was to join these two
data sets so that each row would represent an electoral race that was
petitioned and have information on the election results and petition
attributes.

For this function, I’ve extracted a sample of the data limited to the
constituency of Kakamega, Kenya.

``` r
#use kakamega since it had the most petitions

#data with the election attributes (from the Kenya Election Database)
election_attr <- read.csv("./data/election_dataset.csv")

kable(head(election_attr)) %>% 
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

CandName

</th>

<th style="text-align:left;">

Gender

</th>

<th style="text-align:left;">

PartyCode

</th>

<th style="text-align:left;">

ElecType

</th>

<th style="text-align:right;">

ConstCode.2012

</th>

<th style="text-align:right;">

ValidVotes.

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

RICHARD WECHULI SISA

</td>

<td style="text-align:left;">

M

</td>

<td style="text-align:left;">

NAPK

</td>

<td style="text-align:left;">

PARLIAMENTARY

</td>

<td style="text-align:right;">

199

</td>

<td style="text-align:right;">

4.77

</td>

</tr>

<tr>

<td style="text-align:left;">

TIMOTHY KIPLAGAT KOSGEI

</td>

<td style="text-align:left;">

M

</td>

<td style="text-align:left;">

RC

</td>

<td style="text-align:left;">

PARLIAMENTARY

</td>

<td style="text-align:right;">

199

</td>

<td style="text-align:right;">

0.69

</td>

</tr>

<tr>

<td style="text-align:left;">

JAMES PAUL LUSAMAMBA CHILONGO

</td>

<td style="text-align:left;">

M

</td>

<td style="text-align:left;">

KANU

</td>

<td style="text-align:left;">

PARLIAMENTARY

</td>

<td style="text-align:right;">

199

</td>

<td style="text-align:right;">

14.13

</td>

</tr>

<tr>

<td style="text-align:left;">

JAMES MUTELE WEINDABA

</td>

<td style="text-align:left;">

M

</td>

<td style="text-align:left;">

FPK

</td>

<td style="text-align:left;">

PARLIAMENTARY

</td>

<td style="text-align:right;">

199

</td>

<td style="text-align:right;">

12.76

</td>

</tr>

<tr>

<td style="text-align:left;">

NABWERA DARAJA NABII

</td>

<td style="text-align:left;">

M

</td>

<td style="text-align:left;">

ODM

</td>

<td style="text-align:left;">

PARLIAMENTARY

</td>

<td style="text-align:right;">

199

</td>

<td style="text-align:right;">

27.30

</td>

</tr>

<tr>

<td style="text-align:left;">

JOHN R. MUSWANYI

</td>

<td style="text-align:left;">

M

</td>

<td style="text-align:left;">

MDP

</td>

<td style="text-align:left;">

PARLIAMENTARY

</td>

<td style="text-align:right;">

199

</td>

<td style="text-align:right;">

0.50

</td>

</tr>

</tbody>

</table>

``` r
#data with petition attributes (from the Kenya Law website)
petition_attr <- read.csv("./data/petitions_dataset.csv")

kable(petition_attr) %>%
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

respondent\_name

</th>

<th style="text-align:left;">

respondent\_first\_name

</th>

<th style="text-align:left;">

respondent\_last\_name

</th>

<th style="text-align:left;">

file\_outcome

</th>

<th style="text-align:right;">

number\_of\_petitioners

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Wycliffe Oparanya

</td>

<td style="text-align:left;">

Wycliffe

</td>

<td style="text-align:left;">

Oparanya

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

Enoch Kibunguchy

</td>

<td style="text-align:left;">

Enoch

</td>

<td style="text-align:left;">

Kibunguchy

</td>

<td style="text-align:left;">

petition\_dismissed

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

Benjamin Andayi

</td>

<td style="text-align:left;">

Benjamin

</td>

<td style="text-align:left;">

Andayi

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

Raphael Otaalo

</td>

<td style="text-align:left;">

Raphael

</td>

<td style="text-align:left;">

Otaalo

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

5

</td>

</tr>

<tr>

<td style="text-align:left;">

David Were

</td>

<td style="text-align:left;">

David

</td>

<td style="text-align:left;">

Were

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

Emmanuel Wangwe

</td>

<td style="text-align:left;">

Emmanuel

</td>

<td style="text-align:left;">

Wangwe

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>

### Method 1: Matching names by matching all permutations of names

For respondents, we can merge KED data with the RQDA data using the
constituency and elected position information, since the KED data
indicates who won the election. However, for petitioners, we can only
merge by matching names in addition to using the constituency and
elected position information.

In Kenya, name order (first, middle, last names) are often mixed up.
Matching just the first and last name pairs as recorded in data would
result in a lot of true negatives. Therefore, when matching names of two
lists, the all permutations of a person’s full name must be used.

The KED data has full names, so I first find all possible permutations
name pairs using the KED data.

``` r
### Permutations of the KED names 

#steps needed:
  #1. Extract the full names and split them into single names
  #2. Create all possible permutations of pairs of names


### Spliting Names ###
#KED data has the full names
#What is the longest number of names a person can have?
names_max_length <- max(lengths(strsplit(as.character(election_attr$CandName), " ")))
# P(6,2) = 30, so 30 permutations of the names are needed

#split the full names into single names in order to get all the permulations
candname_split <- as.data.frame(cbind(as.character(election_attr$CandName), 
                                      str_split_fixed(as.character(election_attr$CandName), 
                                                      " ", 
                                                      names_max_length))) %>%
  mutate_all(as.character)


#a way to create a vector to names the columns automatically
for(i in 1:ncol(candname_split)) {
  if(i == 1){
    newcolnames <- c("fullname")
    }
  else {
    newcolnames <- c(newcolnames,
                     paste0("name", i-1))
  }
}

#rename the columns 
names(candname_split) <- newcolnames


### Pemuting all name pairs 
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


#apply this function to the candidate name dataframe to get all the possible pairs of names and merge it with the candidate key and full name
#each row is one candidate
candname_perm <- as.data.frame(cbind(as.character(election_attr$CandName), 
                                     t(apply(candname_split[,2:ncol(candname_split)], 
                                             1, 
                                             permute_paste, 
                                             sample = 2)))) %>%
  mutate_all(as.character) 



#way to create a vector to names the columns automatically for the permutations
for(i in 1:ncol(candname_perm)) {
  if(i == 1){
    newcolnames_perm <- c("fullname")
    }
  else {
    newcolnames_perm <- c(newcolnames_perm,
                     paste0("combination", i-1))
  }
}

#rename the columns 
names(candname_perm) <- newcolnames_perm
```

Now we are ready to match these names to the petitioner names from the
RQDA data (which only have first and last names)

<br> <br>

Matching KED names to RQDA names using agrep (Check this
part):

``` r
#made a new agrep function so that the target (vector where the matches are sought- "combinations") will be the first input and the output would be a dataframe
my_agrep <- function(combinations, source, max){
  list <- sapply(source,
                 agrep,
                 x = combinations,
                 value = T, 
                 ignore.case = T,
                 max = max)
  result <- reshape2::melt(list)  
  result[,1] <- as.character(result[,1])
  return(result)
}


#apply this over all the combinations 
fuzzy_name_match <- apply(candname_perm[,2:ncol(candname_perm)], 
                         2, 
                         my_agrep, 
                         source = petition_attr$respondent_name, 
                         max = 0.065)
```

Now we have all the matches between KED names and RQDA petitioner names

<br> <br>

``` r
#RQDA info with name matches
all_name_matches <- select(bind_rows(fuzzy_name_match), 
                           value) %>%  #df of all possible name matches (name-name is a unit)
  left_join(mutate(petition_attr,
                   respondent_name = toupper(respondent_name)),
            by = c("value" = "respondent_name")) %>%
  rename(matched_name = value)


#need to include election data

kable(all_name_matches) %>%
  kable_styling()
```

<table class="table" style="margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

matched\_name

</th>

<th style="text-align:left;">

respondent\_first\_name

</th>

<th style="text-align:left;">

respondent\_last\_name

</th>

<th style="text-align:left;">

file\_outcome

</th>

<th style="text-align:right;">

number\_of\_petitioners

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

EMMANUEL WANGWE

</td>

<td style="text-align:left;">

Emmanuel

</td>

<td style="text-align:left;">

Wangwe

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:left;">

WYCLIFFE OPRANYAH

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

ENOCH KIBUNGUCHY

</td>

<td style="text-align:left;">

Enoch

</td>

<td style="text-align:left;">

Kibunguchy

</td>

<td style="text-align:left;">

petition\_dismissed

</td>

<td style="text-align:right;">

2

</td>

</tr>

<tr>

<td style="text-align:left;">

BENJAMIN ANDANYI

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:left;">

NA

</td>

<td style="text-align:right;">

NA

</td>

</tr>

<tr>

<td style="text-align:left;">

RAPHAEL OTAALO

</td>

<td style="text-align:left;">

Raphael

</td>

<td style="text-align:left;">

Otaalo

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

5

</td>

</tr>

<tr>

<td style="text-align:left;">

DAVID WERE

</td>

<td style="text-align:left;">

David

</td>

<td style="text-align:left;">

Were

</td>

<td style="text-align:left;">

valid\_election

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>

<br> <br> <br>

##### Other Options (Under construction…)

answer
1

``` r
#split the full names into single names in order to get all the permulations
cand_split_short <- as.data.frame(str_split_fixed(as.character(election_attr$CandName), 
                                                " ",
                                                max(lengths(strsplit(as.character(election_attr$CandName), 
                                                                     " "))))) %>%
  mutate_all(as.character)

petition_split <- as.data.frame(str_split(as.character(petition_attr$respondent_name), 
                                                " ")) %>%
  mutate_all(toupper) 




lst=sapply(petition_split, 
           function(x) paste0(sort(x),
                              collapse=" "))

lst1=gsub("\\s|$",
          ".*",
          lst)

lst2=sapply(cand_split_short,
            function(x) paste(sort(x),
                              collapse=" "))

lst3 = Vectorize(grep)(lst1,
                       list(lst2),
                       value=T,
                       ignore.case=T)


#setNames(cand_split_short[match(lst3,
#                                lst2)],
#         sapply(petition_split[grep(paste0(names(lst3),
#                                                  collapse = "|"),
#                                           lst1)],
#                paste,
#                collapse=" "))
```

answer 2

``` r
apply(sapply(petition_split, 
             unlist), 
      2, 
      function(x){
        any(sapply(cand_split_short, 
                   function(y) sum(unlist(y) %in% x) >= length(x)))
        }
      )
```

    ## c..Wycliffe....Oparanya..  c..Enoch....Kibunguchy.. 
    ##                      TRUE                     FALSE 
    ##   c..Benjamin....Andayi..    c..Raphael....Otaalo.. 
    ##                      TRUE                     FALSE 
    ##        c..David....Were..   c..Emmanuel....Wangwe.. 
    ##                      TRUE                     FALSE
