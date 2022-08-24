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
 * IBM-MDMWB-1.0-[38ac81f56658e9fdfe0ef2b7ed554f87]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.coreParty.bobj.query.ContactMethodBObjQuery;

import com.dwl.tcrm.coreParty.component.TCRMContactMethodBObj;

import com.ibm.daimler.dsea.component.XContactMethodBObjExt;
import com.ibm.daimler.dsea.component.XContactMethodExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXContactMethodExtData;
import com.ibm.daimler.dsea.entityObject.XContactMethodExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>ContactMethodBObjQuery</code> class.
 *
 * @generated
 */
public class XContactMethodExtBObjQuery extends ContactMethodBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XContactMethodExtBObjQuery.class);
   
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
    public XContactMethodExtBObjQuery(String queryName, DWLControl control) {
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
    public XContactMethodExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XContactMethodExtInquiryData.class;
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
    if (objectToPersist instanceof XContactMethodBObjExt) {
      String infoForLogging="persist() instanceof XContactMethodBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(CONTACT_METHOD_ADD)) {
        addXContactMethod();
      }else if(persistenceStrategyName.equals(CONTACT_METHOD_UPDATE)) {
        updateXContactMethod();
      }else if(persistenceStrategyName.equals(CONTACT_METHOD_DELETE)) {
        deleteXContactMethod();
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
      * Inserts xcontactmethod data by calling
      * <code>EObjXContactMethodExtData.createEObjXContactMethod</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXContactMethod() throws Exception{
    logger.finest("ENTER addXContactMethod()");
    EObjXContactMethodExtData theEObjXContactMethodExtData = (EObjXContactMethodExtData) DataAccessFactory
      .getQuery(EObjXContactMethodExtData.class, connection);
 		theEObjXContactMethodExtData.createEObjXContactMethodExt(
 		                                 ((TCRMContactMethodBObj) objectToPersist).getEObjContactMethod(),
 		                                 ((XContactMethodBObjExt) objectToPersist).getEObjXContactMethodExt());
    logger.finest("RETURN addXContactMethod()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcontactmethod data by calling
      * <code>EObjXContactMethodExtData.updateEObjXContactMethod</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXContactMethod() throws Exception{
    logger.finest("ENTER updateXContactMethod()");
    EObjXContactMethodExtData theEObjXContactMethodExtData = (EObjXContactMethodExtData) DataAccessFactory
      .getQuery(EObjXContactMethodExtData.class, connection);
 		theEObjXContactMethodExtData.updateEObjXContactMethodExt(
 		                                 ((TCRMContactMethodBObj) objectToPersist).getEObjContactMethod(),
 		                                 ((XContactMethodBObjExt) objectToPersist).getEObjXContactMethodExt());
    logger.finest("RETURN updateXContactMethod()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xcontactmethod data by calling
      * <code>EObjXContactMethodExtData.deleteEObjXContactMethod</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXContactMethod() throws Exception{
    logger.finest("ENTER deleteXContactMethod()");
    Long id = ((XContactMethodBObjExt) objectToPersist).getEObjContactMethod().getContactMethodIdPK();
    EObjXContactMethodExtData theEObjXContactMethodExtData = (EObjXContactMethodExtData) DataAccessFactory
      .getQuery(EObjXContactMethodExtData.class, connection);
    theEObjXContactMethodExtData.deleteEObjXContactMethodExt(id);
    logger.finest("RETURN deleteXContactMethod()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XContactMethodExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XContactMethodExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XContactMethodExtResultSetProcessor();
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


