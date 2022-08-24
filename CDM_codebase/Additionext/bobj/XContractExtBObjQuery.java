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
 * IBM-MDMWB-1.0-[37a88581f9055f680c0fec613552e364]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.financial.bobj.query.ContractBObjQuery;

import com.dwl.tcrm.financial.component.TCRMContractBObj;

import com.ibm.daimler.dsea.component.XContractBObjExt;
import com.ibm.daimler.dsea.component.XContractExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXContractExtData;
import com.ibm.daimler.dsea.entityObject.XContractExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>ContractBObjQuery</code> class.
 *
 * @generated
 */
public class XContractExtBObjQuery extends ContractBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XContractExtBObjQuery.class);
   
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
    public XContractExtBObjQuery(String queryName, DWLControl control) {
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
    public XContractExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XContractExtInquiryData.class;
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
    if (objectToPersist instanceof XContractBObjExt) {
      String infoForLogging="persist() instanceof XContractBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(CONTRACT_ADD)) {
        addXContract();
      }else if(persistenceStrategyName.equals(CONTRACT_UPDATE)) {
        updateXContract();
      }else if(persistenceStrategyName.equals(CONTRACT_DELETE)) {
        deleteXContract();
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
      * Inserts xcontract data by calling
      * <code>EObjXContractExtData.createEObjXContract</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXContract() throws Exception{
    logger.finest("ENTER addXContract()");
    EObjXContractExtData theEObjXContractExtData = (EObjXContractExtData) DataAccessFactory
      .getQuery(EObjXContractExtData.class, connection);
 		theEObjXContractExtData.createEObjXContractExt(
 		                                 ((TCRMContractBObj) objectToPersist).getEObjContract(),
 		                                 ((XContractBObjExt) objectToPersist).getEObjXContractExt());
    logger.finest("RETURN addXContract()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcontract data by calling
      * <code>EObjXContractExtData.updateEObjXContract</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXContract() throws Exception{
    logger.finest("ENTER updateXContract()");
    EObjXContractExtData theEObjXContractExtData = (EObjXContractExtData) DataAccessFactory
      .getQuery(EObjXContractExtData.class, connection);
 		theEObjXContractExtData.updateEObjXContractExt(
 		                                 ((TCRMContractBObj) objectToPersist).getEObjContract(),
 		                                 ((XContractBObjExt) objectToPersist).getEObjXContractExt());
    logger.finest("RETURN updateXContract()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xcontract data by calling
      * <code>EObjXContractExtData.deleteEObjXContract</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXContract() throws Exception{
    logger.finest("ENTER deleteXContract()");
    Long id = ((XContractBObjExt) objectToPersist).getEObjContract().getContractIdPK();
    EObjXContractExtData theEObjXContractExtData = (EObjXContractExtData) DataAccessFactory
      .getQuery(EObjXContractExtData.class, connection);
    theEObjXContractExtData.deleteEObjXContractExt(id);
    logger.finest("RETURN deleteXContract()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XContractExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XContractExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XContractExtResultSetProcessor();
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


