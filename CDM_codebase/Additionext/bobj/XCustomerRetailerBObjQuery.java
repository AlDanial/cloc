
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
 * IBM-MDMWB-1.0-[71a7800ef581995eb05254512483abbd]
 */
package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;

import com.dwl.base.db.DataAccessFactory;


import com.dwl.base.error.DWLErrorCode;
import com.dwl.base.error.DWLStatus;

import com.dwl.base.exception.DWLDuplicateKeyException;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.base.util.DWLClassFactory;
import com.dwl.base.util.DWLExceptionUtils;

import com.ibm.daimler.dsea.component.XCustomerRetailerBObj;
import com.ibm.daimler.dsea.component.XCustomerRetailerResultSetProcessor;

import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsComponentID;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsErrorReasonCode;

import com.ibm.daimler.dsea.entityObject.EObjXCustomerRetailerData;
import com.ibm.daimler.dsea.entityObject.XCustomerRetailerInquiryData;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class provides query information for the business object
 * <code>XCustomerRetailerBObj</code>.
 *
 * @generated
 */
public class XCustomerRetailerBObjQuery  extends com.dwl.bobj.query.GenericBObjQuery {

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_RETAILER_QUERY = "getXCustomerRetailer(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_RETAILER_HISTORY_QUERY = "getXCustomerRetailerHistory(Object[])";

	/**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_RETAILER_BY_PARTY_ID_QUERY = "getAllXCustomerRetailerByPartyId(Object[])";

    /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_RETAILER_BY_PARTY_ID_HISTORY_QUERY = "getAllXCustomerRetailerByPartyIdHistory(Object[])";

  /**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XCustomerRetailerBObjQuery.class);
     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_RETAILER_ADD = "XCUSTOMER_RETAILER_ADD";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_RETAILER_DELETE = "XCUSTOMER_RETAILER_DELETE";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_RETAILER_UPDATE = "XCUSTOMER_RETAILER_UPDATE";


    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @param queryName
     * The name of the query.
     * @param control
     * The control object.
     *
     * @generated
     */
    public XCustomerRetailerBObjQuery(String queryName, DWLControl control) {
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
    public XCustomerRetailerBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
        super(persistenceStrategyName, objectToPersist);
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
    if (persistenceStrategyName.equals(XCUSTOMER_RETAILER_ADD)) {
      addXCustomerRetailer();
    }else if(persistenceStrategyName.equals(XCUSTOMER_RETAILER_UPDATE)) {
      updateXCustomerRetailer();
    }else if(persistenceStrategyName.equals(XCUSTOMER_RETAILER_DELETE)) {
      deleteXCustomerRetailer();
    }
    logger.finest("RETURN persist()");
  }
  
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xcustomerretailer data by calling
      * <code>EObjXCustomerRetailerData.createEObjXCustomerRetailer</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXCustomerRetailer() throws Exception{
    logger.finest("ENTER addXCustomerRetailer()");
    
    EObjXCustomerRetailerData theEObjXCustomerRetailerData = (EObjXCustomerRetailerData) DataAccessFactory
      .getQuery(EObjXCustomerRetailerData.class, connection);
    theEObjXCustomerRetailerData.createEObjXCustomerRetailer(((XCustomerRetailerBObj) objectToPersist).getEObjXCustomerRetailer());
    logger.finest("RETURN addXCustomerRetailer()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcustomerretailer data by calling
      * <code>EObjXCustomerRetailerData.updateEObjXCustomerRetailer</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXCustomerRetailer() throws Exception{
    logger.finest("ENTER updateXCustomerRetailer()");
    EObjXCustomerRetailerData theEObjXCustomerRetailerData = (EObjXCustomerRetailerData) DataAccessFactory
      .getQuery(EObjXCustomerRetailerData.class, connection);
    theEObjXCustomerRetailerData.updateEObjXCustomerRetailer(((XCustomerRetailerBObj) objectToPersist).getEObjXCustomerRetailer());
    logger.finest("RETURN updateXCustomerRetailer()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes {0} data by calling <{1}>{2}.{3}{4}</{1}>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXCustomerRetailer() throws Exception{
    logger.finest("ENTER deleteXCustomerRetailer()");
         // MDM_TODO: CDKWB0018I Write customized business logic for the extension here.
    logger.finest("RETURN deleteXCustomerRetailer()");
  } 
  
    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * This method is overridden to construct
      * <code>DWLDuplicateKeyException</code> based on XCustomerRetailer
      * component specific values.
     * 
     * @param errParams
     * The values to be substituted in the error message.
   *
     * @throws Exception
     *
     * @generated
     */
    protected void throwDuplicateKeyException(String[] errParams) throws Exception {
    if (logger.isFinestEnabled()) {
      	StringBuilder errParamsStringBuilder = new StringBuilder("Error: Duplicate key Exception parameters are ");
      	for(int i=0;i<errParams.length;i++) {
      		errParamsStringBuilder .append(errParams[i]);
      		if (i!=errParams.length-1) {
      			errParamsStringBuilder .append(" , ");
      		}
      	}
          String infoForLogging="Error: Duplicate key Exception parameters are " + errParamsStringBuilder;
      logger.finest("Unknown method " + infoForLogging);
    }
    	DWLExceptionUtils.throwDWLDuplicateKeyException(
    		new DWLDuplicateKeyException(buildDupThrowableMessage(errParams)),
    		objectToPersist.getStatus(), 
    		DWLStatus.FATAL,
    		DSEAAdditionsExtsComponentID.DSEAADDITIONS_EXTS_COMPONENT,
    		DWLErrorCode.DUPLICATE_KEY_ERROR, 
    		DSEAAdditionsExtsErrorReasonCode.DUPLICATE_PRIMARY_KEY_XCUSTOMERRETAILER,
    		objectToPersist.getControl(), 
    		DWLClassFactory.getErrorHandler()
    		);
    }
    
    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XCustomerRetailerResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XCustomerRetailerResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XCustomerRetailerResultSetProcessor();
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    @Override
    protected Class<XCustomerRetailerInquiryData> provideQueryInterfaceClass() throws BObjQueryException {
        return XCustomerRetailerInquiryData.class;
    }

}


