# soql-query-builder
**SOQL Query Builder** lets you write your long **SOQL** queries in more organized and readable fashion. It also supports **"*"** and automatically queries all the fields for a given object.

## How to use?
### 1. Quering all the fields
```
String soql = new QueryBuilder()
                  .sel('*')
                  .frm('Contact')
                  .soql();
System.debug(soql);
```
### 2. Selecting specific fields
```
String soql = new QueryBuilder()
                  .sel('FirstName')
                  .sel(new Set<String>{ 'LastName', 'Email' })
                  .sel(new List<String>{ 'Phone', 'Department' })
                  .frm('Contact')
                  .soql();
System.debug(soql);
```
Outputs to
```
SELECT FirstName,LastName,Email,Phone,Department FROM Contact
```
### 3. Filtering records
```
String soql = new QueryBuilder()
                  .sel('FirstName')
                  .sel('LastName')
                  .frm('Contact')
                  .whr('Department != null')
                  .whr('Level__c = \'Primary\'')
                  .soql();
System.debug(soql);
```
Outputs to
```
SELECT FirstName,LastName FROM Contact WHERE Department != null AND Level__c = 'Primary'
```
