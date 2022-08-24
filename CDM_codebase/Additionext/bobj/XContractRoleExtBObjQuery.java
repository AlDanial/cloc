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
 * IBM-MDMWB-1.0-[6e8577cffc5eed1231d064b0528557d9]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.financial.bobj.query.ContractPartyRoleBObjQuery;

import com.dwl.tcrm.financial.component.TCRMContractPartyRoleBObj;

import com.ibm.daimler.dsea.component.XContractRoleBObjExt;
import com.ibm.daimler.dsea.component.XContractRoleExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXContractRoleExtData;
import com.ibm.daimler.dsea.entityObject.XContractRoleExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>ContractPartyRoleBObjQuery</code> class.
 *
 * @generated
 */
public class XContractRoleExtBObjQuery extends ContractPartyRoleBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XContractRoleExtBObjQuery.class);
   
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
    public XContractRoleExtBObjQuery(String queryName, DWLControl control) {
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
    public XContractRoleExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XContractRoleExtInquiryData.class;
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
    if (objectToPersist instanceof XContractRoleBObjExt) {
      String infoForLogging="persist() instanceof XContractRoleBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(CONTRACT_PARTY_ROLE_ADD)) {
        addXContractRole();
      }else if(persistenceStrategyName.equals(CONTRACT_PARTY_ROLE_UPDATE)) {
        updateXContractRole();
      }else if(persistenceStrategyName.equals(CONTRACT_PARTY_ROLE_DELETE)) {
        deleteXContractRole();
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
      * Inserts xcontractrole data by calling
      * <code>EObjXContractRoleExtData.createEObjXContractRole</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXContractRole() throws Exception{
    logger.finest("ENTER addXContractRole()");
    EObjXContractRoleExtData theEObjXContractRoleExtData = (EObjXContractRoleExtData) DataAccessFactory
      .getQuery(EObjXContractRoleExtData.class, connection);
 		theEObjXContractRoleExtData.createEObjXContractRoleExt(
 		                                 ((TCRMContractPartyRoleBObj) objectToPersist).getEObjContractRole(),
 		                                 ((XContractRoleBObjExt) objectToPersist).getEObjXContractRoleExt());
    logger.finest("RETURN addXContractRole()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcontractrole data by calling
      * <code>EObjXContractRoleExtData.updateEObjXContractRole</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXContractRole() throws Exception{
    logger.finest("ENTER updateXContractRole()");
    EObjXContractRoleExtData theEObjXContractRoleExtData = (EObjXContractRoleExtData) DataAccessFactory
      .getQuery(EObjXContractRoleExtData.class, connection);
 		theEObjXContractRoleExtData.updateEObjXContractRoleExt(
 		                                 ((TCRMContractPartyRoleBObj) objectToPersist).getEObjContractRole(),
 		                                 ((XContractRoleBObjExt) objectToPersist).getEObjXContractRoleExt());
    logger.finest("RETURN updateXContractRole()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xcontractrole data by calling
      * <code>EObjXContractRoleExtData.deleteEObjXContractRole</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXContractRole() throws Exception{
    logger.finest("ENTER deleteXContractRole()");
    Long id = ((XContractRoleBObjExt) objectToPersist).getEObjContractRole().getContractRoleIdPK();
    EObjXContractRoleExtData theEObjXContractRoleExtData = (EObjXContractRoleExtData) DataAccessFactory
      .getQuery(EObjXContractRoleExtData.class, connection);
    theEObjXContractRoleExtData.deleteEObjXContractRoleExt(id);
    logger.finest("RETURN deleteXContractRole()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XContractRoleExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XContractRoleExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XContractRoleExtResultSetProcessor();
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


