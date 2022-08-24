/*
 * The following source code ("Code") may only be used in accordance with the terms
 * and conditions of the license agreement you have with IBM Corporation. The Code 
 * is provided to you on an "AS IS" basis, without warranty of any kind.  
 * SUBJECT TO ANY STATUTORY WARRANTIES WHICH CAN NOT BE EXCLUDED, IBM MAKES NO 
 * WARRANTIES OR CONDITIONS EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED 
 * TO, THE IMPLIED WARRANTIES OR CONDITIONS OF MERCHANTABILITY, FITNESS FOR A 
 * PARTICULAR PURPOSE, AND NON-INFRINGEMENT, REGARDING THE CODE. IN NO EVENT WILL 
 * IBM BE LIABLE TO YOU OR ANY PARTY FOR ANY DIRECT, INDIRECT, SPECIAL OR OTHER 
 * CONSEQUENTIAL DAMAGES FOR ANY USE OF THE CODE, INCLUDING, WITHOUT LIMITATION, 
 * LOSS OF, OR DAMAGE TO, DATA, OR LOST PROFITS, BUSINESS, REVENUE, GOODWILL, OR 
 * ANTICIPATED SAVINGS, EVEN IF IBM HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH 
 * DAMAGES. SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OR LIMITATION OF 
 * INCIDENTAL OR CONSEQUENTIAL DAMAGES, SO THE ABOVE LIMITATION OR EXCLUSION MAY 
 * NOT APPLY TO YOU.
 */

/*
 * IBM-MDMWB-1.0-[99390e56961f6ae55c8a195ffe537eb0]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.coreParty.bobj.query.PersonBObjQuery;

import com.dwl.tcrm.coreParty.component.TCRMPersonBObj;

import com.ibm.daimler.dsea.component.XPersonBObjExt;
import com.ibm.daimler.dsea.component.XPersonExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXPersonExtData;
import com.ibm.daimler.dsea.entityObject.XPersonExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>PersonBObjQuery</code> class.
 *
 * @generated
 */
public class XPersonExtBObjQuery extends PersonBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XPersonExtBObjQuery.class);
   
   /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @param queryName
     *     The name of the query.
     * @param control
     *     The control object.
     *
     * @generated
     */
    public XPersonExtBObjQuery(String queryName, DWLControl control) {
        super(queryName, control);
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @param persistenceStrategyName
     * The persistence strategy name.  This parameter indicates the type of
     * database action to be taken such as addition, update or deletion of
     * records.
     * @param objectToPersist
     * The business object to be persisted.
     *
     * @generated
     */
    public XPersonExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
        super(persistenceStrategyName, objectToPersist);
    }


    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
     @SuppressWarnings("rawtypes")
    protected Class provideQueryInterfaceClass()  throws BObjQueryException  {
        return XPersonExtInquiryData.class;
    }
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
	protected void persist() throws Exception{
    logger.finest("ENTER persist()");
    if (logger.isFinestEnabled()) {
    		String infoForLogging="Persistence strategy is " + persistenceStrategyName;
      logger.finest("persist() " + infoForLogging);
    }
    if (logger.isFinestEnabled()) {
      String infoForLogging=" Extension with fields added to DB table";
      logger.finest("persist() " + infoForLogging);
    }
    if (objectToPersist instanceof XPersonBObjExt) {
      String infoForLogging="persist() instanceof XPersonBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(PERSON_ADD)) {
        addXPerson();
      }else if(persistenceStrategyName.equals(PERSON_UPDATE)) {
        updateXPerson();
      }else if(persistenceStrategyName.equals(PERSON_DELETE)) {
        deleteXPerson();
      }else {
        super.persist();
      }
    } else {
      if (logger.isFinestEnabled()) {
        String infoForLogging="Call super.persist()";
      logger.finest("persist() " + infoForLogging);
      }
      super.persist();
    }		
    
    logger.finest("RETURN persist()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xperson data by calling
      * <code>EObjXPersonExtData.createEObjXPerson</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXPerson() throws Exception{
    logger.finest("ENTER addXPerson()");
    EObjXPersonExtData theEObjXPersonExtData = (EObjXPersonExtData) DataAccessFactory
      .getQuery(EObjXPersonExtData.class, connection);
 		theEObjXPersonExtData.createEObjXPersonExt(
 		                                 ((TCRMPersonBObj) objectToPersist).getEObjPerson(),
 		                                 ((XPersonBObjExt) objectToPersist).getEObjXPersonExt());
    logger.finest("RETURN addXPerson()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xperson data by calling
      * <code>EObjXPersonExtData.updateEObjXPerson</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXPerson() throws Exception{
    logger.finest("ENTER updateXPerson()");
    EObjXPersonExtData theEObjXPersonExtData = (EObjXPersonExtData) DataAccessFactory
      .getQuery(EObjXPersonExtData.class, connection);
 		theEObjXPersonExtData.updateEObjXPersonExt(
 		                                 ((TCRMPersonBObj) objectToPersist).getEObjPerson(),
 		                                 ((XPersonBObjExt) objectToPersist).getEObjXPersonExt());
    logger.finest("RETURN updateXPerson()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xperson data by calling
      * <code>EObjXPersonExtData.deleteEObjXPerson</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXPerson() throws Exception{
    logger.finest("ENTER deleteXPerson()");
    Long id = ((XPersonBObjExt) objectToPersist).getEObjPerson().getContIdPK();
    EObjXPersonExtData theEObjXPersonExtData = (EObjXPersonExtData) DataAccessFactory
      .getQuery(EObjXPersonExtData.class, connection);
    theEObjXPersonExtData.deleteEObjXPersonExt(id);
    logger.finest("RETURN deleteXPerson()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XPersonExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XPersonExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XPersonExtResultSetProcessor();
    }    


    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    protected String getSQLStatement() throws BObjQueryException {
        String sql = super.getSQLStatement();
        if (sql != null) {
            return sql;
        }
        return getSQLStatement(super.provideQueryInterfaceClass());
    }
}


