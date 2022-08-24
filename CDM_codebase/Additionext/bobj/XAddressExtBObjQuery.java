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
 * IBM-MDMWB-1.0-[122c4e86ed50545fc217504390e5668e]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.coreParty.bobj.query.AddressBObjQuery;

import com.dwl.tcrm.coreParty.component.TCRMAddressBObj;

import com.ibm.daimler.dsea.component.XAddressBObjExt;
import com.ibm.daimler.dsea.component.XAddressExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXAddressExtData;
import com.ibm.daimler.dsea.entityObject.XAddressExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>AddressBObjQuery</code> class.
 *
 * @generated
 */
public class XAddressExtBObjQuery extends AddressBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XAddressExtBObjQuery.class);
   
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
    public XAddressExtBObjQuery(String queryName, DWLControl control) {
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
    public XAddressExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XAddressExtInquiryData.class;
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
    if (objectToPersist instanceof XAddressBObjExt) {
      String infoForLogging="persist() instanceof XAddressBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(ADDRESS_ADD)) {
        addXAddress();
      }else if(persistenceStrategyName.equals(ADDRESS_UPDATE)) {
        updateXAddress();
      }else if(persistenceStrategyName.equals(ADDRESS_DELETE)) {
        deleteXAddress();
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
      * Inserts xaddress data by calling
      * <code>EObjXAddressExtData.createEObjXAddress</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXAddress() throws Exception{
    logger.finest("ENTER addXAddress()");
    EObjXAddressExtData theEObjXAddressExtData = (EObjXAddressExtData) DataAccessFactory
      .getQuery(EObjXAddressExtData.class, connection);
 		theEObjXAddressExtData.createEObjXAddressExt(
 		                                 ((TCRMAddressBObj) objectToPersist).getEObjAddress(),
 		                                 ((XAddressBObjExt) objectToPersist).getEObjXAddressExt());
    logger.finest("RETURN addXAddress()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xaddress data by calling
      * <code>EObjXAddressExtData.updateEObjXAddress</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXAddress() throws Exception{
    logger.finest("ENTER updateXAddress()");
    EObjXAddressExtData theEObjXAddressExtData = (EObjXAddressExtData) DataAccessFactory
      .getQuery(EObjXAddressExtData.class, connection);
 		theEObjXAddressExtData.updateEObjXAddressExt(
 		                                 ((TCRMAddressBObj) objectToPersist).getEObjAddress(),
 		                                 ((XAddressBObjExt) objectToPersist).getEObjXAddressExt());
    logger.finest("RETURN updateXAddress()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xaddress data by calling
      * <code>EObjXAddressExtData.deleteEObjXAddress</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXAddress() throws Exception{
    logger.finest("ENTER deleteXAddress()");
    Long id = ((XAddressBObjExt) objectToPersist).getEObjAddress().getAddressIdPK();
    EObjXAddressExtData theEObjXAddressExtData = (EObjXAddressExtData) DataAccessFactory
      .getQuery(EObjXAddressExtData.class, connection);
    theEObjXAddressExtData.deleteEObjXAddressExt(id);
    logger.finest("RETURN deleteXAddress()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XAddressExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XAddressExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XAddressExtResultSetProcessor();
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


