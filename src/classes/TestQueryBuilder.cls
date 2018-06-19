/*
 ================================================
 | Test class for QueryBuilder     				|
 |												|
 | @author	Jagdeep Sharma						|
 | @version	1.0									|
 | @since	2018-05-18							|
 ================================================
 */
@isTest
private class TestQueryBuilder {
	
	@isTest static void testSelect() {
		String soql = new QueryBuilder()
						  .sel('Id')
						  .sel('Name')
						  .frm('Account')
						  .soql();

		system.assertEquals('select id,name from account', soql.toLowerCase());	

		Set<String> fieldSet = new Set<String>{'Id', 'Name'};
		soql = new QueryBuilder()
				   .sel(fieldSet)
				   .frm('Account')
				   .soql();

		system.assertEquals('select id,name from account', soql.toLowerCase());	

		List<String> fieldList = new List<String>{'Id', 'Name'};
		soql = new QueryBuilder()
				   .sel(fieldList)
				   .frm('Account')
				   .soql();

		system.assertEquals('select id,name from account', soql.toLowerCase());

		soql = new QueryBuilder()
				   .sel('*')
				   .frm('Account')
				   .soql();

		system.assert(soql.toLowerCase().contains('name'));
		system.assert(soql.toLowerCase().contains('industry'));
		system.assert(soql.toLowerCase().contains('ownerid'));
			
	}

	@isTest static void testWhere() {
		String soql = new QueryBuilder()
						  .sel('Id')
						  .sel('Name')
						  .frm('Account')
						  .whr('Name=\'sfdc\'')
						  .whr('Industry=\'Retail\'')
						  .soql();

		system.assertEquals('select id,name from account where name=\'sfdc\' and industry=\'retail\'', soql.toLowerCase());	

		soql = new QueryBuilder()
				  .sel('Id')
				  .sel('Name')
				  .frm('Account')
				  .whr('Name=\'sfdc\'', 1)
				  .whr('Industry=\'Retail\'', 2)
				  .advwhr('1 OR 2')
				  .soql();

		system.assertEquals('select id,name from account where name=\'sfdc\' or industry=\'retail\'', soql.toLowerCase());	

	}

	@isTest static void testSorting() {
		String soql = new QueryBuilder()
						  .sel('Id')
						  .sel('FirstName')
						  .frm('Contact')
						  .sort('Name')
						  .soql();

		system.assertEquals('select id,firstname from contact order by name asc', soql.toLowerCase());	

		soql = new QueryBuilder()
				  .sel('Id')
				  .sel('FirstName')
				  .frm('Contact')
				  .sort('Name', 'DESC')
				  .soql();

		system.assertEquals('select id,firstname from contact order by name desc', soql.toLowerCase());	

		List<String> fieldList = new List<String>{'FirstName', 'LastName'};
		soql = new QueryBuilder()
						  .sel('Id')
						  .sel('FirstName')
						  .frm('Contact')
						  .sort(fieldList, 'DESC')
						  .soql();

		system.assertEquals('select id,firstname from contact order by firstname desc,lastname desc', soql.toLowerCase());				

		soql = new QueryBuilder()
						  .sel('Id')
						  .sel('FirstName')
						  .frm('Contact')
						  .sort(fieldList)
						  .soql();

		system.assertEquals('select id,firstname from contact order by firstname asc,lastname asc', soql.toLowerCase());		
	}

	@isTest static void testSubquery() {
		String soql = new QueryBuilder()
						  .sel('Id')
						  .sel('Name')
						  .sub(new QueryBuilder()
						  			.sel('*')
						  			.frm('Contacts'))
						  .frm('Account')
						  .lmt(5)
						  .soql();

		system.assert(soql.toLowerCase().contains('limit=5'));
		system.assert(soql.toLowerCase().contains('FirstName'));			
	}
	
}