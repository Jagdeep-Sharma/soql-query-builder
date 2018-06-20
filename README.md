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
**Note: This is a costly operations and could slowdown your application. Please make sure that the queried object doesn't have any Rich-Text or Long-Text area fields.**
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
### 4. Advanced Filtering
```
String soql = new QueryBuilder()
                  .sel('FirstName')
                  .sel('LastName')
                  .frm('Contact')
                  .whr('Department != null', 1)
                  .whr('Department = \'Internal Operations\'', 2)
                  .whr('Level__c != null', 3)
                  .whr('Level__c = \'Primary\'', 4)
                  .advwhr('(1 AND 2) OR (3 AND 4)')
                  .soql();
System.debug(soql);
```
Outputs to
```
SELECT FirstName,LastName FROM Contact WHERE (Department != null AND Department = 'Internal Operations') OR (Level__c != null AND Level__c = 'Primary')
```
### 5. Subqueries / Nested queries
```
String soql = new QueryBuilder()
                  .sel('Id')
                  .sel('Name')
                  .sub(new QueryBuilder()
                           .sel('FirstName')
                           .sel('LastName')
                           .frm('Contacts')
                           .lmt(5))
                  .frm('Account')
                  .soql();
System.debug(soql);
```
Outputs to
```
SELECT Id,Name,(SELECT FirstName,LastName FROM Contacts LIMIT 5) FROM Account
```

### 6. Sorting / Limiting records
```
String soql = new QueryBuilder()
                  .sel('FirstName')
                  .sel('LastName')
                  .frm('Contact')
                  .sort('FirstName')
                  .sort('LastName', 'DESC')
                  .lmt(5)
                  .soql();
System.debug(soql);
```
Outputs to 
```
SELECT FirstName,LastName FROM Contact ORDER BY FirstName ASC,LastName DESC LIMIT 5
```
## Authors
- **Jagdeep Sharma**
