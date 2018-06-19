/*
 ================================================
 | 				(QueryBuilder)					|
 | An apex class to build your SOQL queries     |
 |												|
 | @author	Jagdeep Sharma						|
 | @version	1.0									|
 | @since	2018-05-18							|
 ================================================
 */
public class QueryBuilder {
	private List<Object> fieldList = new List<Object>();
	private String fromObject = null;
	private List<String> whereList = new List<String>();
	private Map<Integer, String> whereMap = new Map<Integer, String>();
	private Map<String, String> orderByMap = new Map<String, String>();
	private String advancedCondition;
	private Integer lmt = 0;
	private QueryBuilder parent = null;
	private Boolean isSelectAll = false;
	private Boolean isSubquery = false;

	// Constants
	private static final String DEFAULT_SORT_ORDER = 'ASC';
	private static final Map<String, Schema.SObjectType> GD = Schema.getGlobalDescribe();


	/* 
	 ====================
	 | 					|
	 | PUBLIC METHODS	|
	 |					|
	 ====================
	 */

	public QueryBuilder sel(String fieldName) {
		if (fieldName.trim() == '*') {
			isSelectAll = true;
		} 
		else {
			fieldList.add(fieldName);
		}		
		return this;
	}

	public QueryBuilder sel(Set<String> fieldNames) {
		for (String fieldName : fieldNames) {
			fieldList.add(fieldName);
		}
		return this;
	}

	public QueryBuilder sel(List<String> fieldNames) {
		for (String fieldName : fieldNames) {
			fieldList.add(fieldName);
		}
		return this;
	}

	public QueryBuilder sub(QueryBuilder subquery) {
		subquery.setSubqueryFlag(true);
		subquery.setParent(this);
		fieldList.add(subquery);
		return this;
	}

	public QueryBuilder frm(String objectName) {
		fromObject = objectName;
		return this;
	}

	public QueryBuilder whr(String expr) {
		whereList.add(expr);
		return this;
	}

	public QueryBuilder whr(String expr, Integer index) {
		whereMap.put(index, expr);
		return this;
	}

	public QueryBuilder advWhr(String expr) {
		advancedCondition = expr;
		return this;
	}

	public QueryBuilder sort(String fieldName) {
		orderByMap.put(fieldName, DEFAULT_SORT_ORDER);
		return this;
	}

	public QueryBuilder sort(String fieldName, String order) {
		orderByMap.put(fieldName, order);
		return this;
	}

	public QueryBuilder sort(List<String> fieldNames) {
		for (String fieldName : fieldNames)
			sort(fieldName);
		return this;
	}

	public QueryBuilder sort(Set<String> fieldNames) {
		for (String fieldName : fieldNames)
			sort(fieldName);
		return this;
	}

	public QueryBuilder sort(List<String> fieldNames, String order) {
		for (String fieldName : fieldNames)
			sort(fieldName, order);
		return this;
	}

	public QueryBuilder sort(Set<String> fieldNames, String order) {
		for (String fieldName : fieldNames)
			sort(fieldName, order);
		return this;
	}

	public QueryBuilder lmt(Integer lmt) {
		this.lmt = lmt;
		return this;
	}

	public String soql() {
		String qry = buildSelect();

		qry += ' FROM ' + fromObject;

		qry += buildWhere();

		qry += buildOrderBy();

		if (lmt > 0) {
			qry += ' LIMIT ' + lmt;
		}

		return qry;
	}

	/* 
	 ====================
	 | 					|
	 | PRIVATE METHODS	|
	 |					|
	 ====================
	 */

	private void setSubqueryFlag(Boolean flag) {
		this.isSubquery = flag;
	}

	private void setParent(QueryBuilder qb) {
		this.parent = qb;
	}

	private String getFromObjectName() {
		return fromObject;
	}

	private String buildSelect() {
		String sel = '';

		if (isSelectAll) {
			sel += String.join(getAllFieldNames(fromObject), ',') + ',';
		}

		for (Object obj : fieldList) {
			if (obj instanceof String) {
				sel += (String) obj + ',';
			} 
			else if (obj instanceof QueryBuilder) {
				QueryBuilder qb = (QueryBuilder) obj;
				sel += '(' + qb.soql() + '),';
			}
		}

		return (sel != '') ? 'SELECT ' + sel.removeEnd(',') : sel;
	}

	private String buildWhere() {
		if (whereList.isEmpty() && advancedCondition == null) {
			return '';
		}
		
		String whr = ' WHERE ';

		if (advancedCondition != null) {
			String advCond = advancedCondition;
			List<Integer> keylist = new List<Integer>(whereMap.keySet());
			keylist.sort();

			List<Integer> descList = new List<Integer>();
			for (Integer index : keylist) {
				if (descList.isEmpty())descList.add(index);
	            else descList.add(0, index);
			}

			for (Integer index : descList) {
				advCond = advCond.replaceAll(String.valueof(index), 'X'+index+'X');
			}

			for (Integer index : descList) {
				String val = whereMap.get(index);
				advCond = advCond.replaceAll('X'+index+'X', val);
			}	

			whr += advCond;
		} else {

			whr += String.join(whereList, ' AND ');
		}

		return whr;
	}

	private String buildOrderBy() {
		if (orderByMap.isEmpty()) return '';

		String orderBy = ' ORDER BY ';

		for (String fieldName : orderByMap.keySet()) {
			String order = orderByMap.get(fieldName);
			orderBy += fieldName + ' ' + order + ',';
		}

		return orderBy.removeEnd(',');
	}

	private List<String> getAllFieldNames(String objectName) {
		Schema.SObjectType objectToken = getObjectToken(objectName);
		return getAllFieldNames(objectToken);
	}

	private List<String> getAllFieldNames(Schema.SObjectType objectToken) {
		Schema.DescribeSObjectResult dsr = objectToken.getDescribe();		
		return new List<String>(dsr.fields.getMap().keySet());
	}

	private Schema.SObjectType getObjectToken(String objectName) {
		if (isSubquery) {
			// In subquery object name is actually child relationship name
			String childRelationshipName = objectName;
			String parentObjectName = parent.getFromObjectName();
			Schema.SObjectType parentToken = GD.get(parentObjectName);
			return getChildToken(parentToken, childRelationshipName);
		}

		return GD.get(objectName);		
	}

	private Schema.SObjectType getChildToken(Schema.SObjectType parentToken, String childRelationshipName) {
		Schema.DescribeSObjectResult dsr = parentToken.getDescribe();
		List<Schema.ChildRelationship> childRelationships = dsr.getChildRelationships();

		for (Schema.ChildRelationship c : childRelationships) {
			if (c.getRelationshipName() == childRelationshipName) {
				return c.getChildSObject();
			}
		}

		return null;
	}

}