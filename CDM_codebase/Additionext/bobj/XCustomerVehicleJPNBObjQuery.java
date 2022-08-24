
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
 * IBM-MDMWB-1.0-[4b8c48795f15d31e148ef9cbce383f4e]
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

import com.ibm.daimler.dsea.component.XCustomerVehicleJPNBObj;
import com.ibm.daimler.dsea.component.XCustomerVehicleJPNResultSetProcessor;

import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsComponentID;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsErrorReasonCode;

import com.ibm.daimler.dsea.entityObject.EObjXCustomerVehicleJPNData;
import com.ibm.daimler.dsea.entityObject.XCustomerVehicleJPNInquiryData;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class provides query information for the business object
 * <code>XCustomerVehicleJPNBObj</code>.
 *
 * @generated
 */
public class XCustomerVehicleJPNBObjQuery  extends com.dwl.bobj.query.GenericBObjQuery {

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_JPN_QUERY = "getXCustomerVehicleJPN(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_JPN_HISTORY_QUERY = "getXCustomerVehicleJPNHistory(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_JPNBY_PARTY_ID_QUERY = "getAllXCustomerVehicleJPNByPartyId(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_JPNBY_PARTY_ID_HISTORY_QUERY = "getAllXCustomerVehicleJPNByPartyIdHistory(Object[])";

	/**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_CVRBY_VEHICLE_ID_QUERY = "getAllCVRByVehicleId(Object[])";

    /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_CVRBY_VEHICLE_ID_HISTORY_QUERY = "getAllCVRByVehicleIdHistory(Object[])";

  /**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XCustomerVehicleJPNBObjQuery.class);
     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_JPN_ADD = "XCUSTOMER_VEHICLE_JPN_ADD";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_JPN_DELETE = "XCUSTOMER_VEHICLE_JPN_DELETE";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_JPN_UPDATE = "XCUSTOMER_VEHICLE_JPN_UPDATE";


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
    public XCustomerVehicleJPNBObjQuery(String queryName, DWLControl control) {
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
    public XCustomerVehicleJPNBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
    if (persistenceStrategyName.equals(XCUSTOMER_VEHICLE_JPN_ADD)) {
      addXCustomerVehicleJPN();
    }else if(persistenceStrategyName.equals(XCUSTOMER_VEHICLE_JPN_UPDATE)) {
      updateXCustomerVehicleJPN();
    }else if(persistenceStrategyName.equals(XCUSTOMER_VEHICLE_JPN_DELETE)) {
      deleteXCustomerVehicleJPN();
    }
    logger.finest("RETURN persist()");
  }
  
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xcustomervehiclejpn data by calling
      * <code>EObjXCustomerVehicleJPNData.createEObjXCustomerVehicleJPN</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXCustomerVehicleJPN() throws Exception{
    logger.finest("ENTER addXCustomerVehicleJPN()");
    
    EObjXCustomerVehicleJPNData theEObjXCustomerVehicleJPNData = (EObjXCustomerVehicleJPNData) DataAccessFactory
      .getQuery(EObjXCustomerVehicleJPNData.class, connection);
    theEObjXCustomerVehicleJPNData.createEObjXCustomerVehicleJPN(((XCustomerVehicleJPNBObj) objectToPersist).getEObjXCustomerVehicleJPN());
    logger.finest("RETURN addXCustomerVehicleJPN()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcustomervehiclejpn data by calling
      * <code>EObjXCustomerVehicleJPNData.updateEObjXCustomerVehicleJPN</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXCustomerVehicleJPN() throws Exception{
    logger.finest("ENTER updateXCustomerVehicleJPN()");
    EObjXCustomerVehicleJPNData theEObjXCustomerVehicleJPNData = (EObjXCustomerVehicleJPNData) DataAccessFactory
      .getQuery(EObjXCustomerVehicleJPNData.class, connection);
    theEObjXCustomerVehicleJPNData.updateEObjXCustomerVehicleJPN(((XCustomerVehicleJPNBObj) objectToPersist).getEObjXCustomerVehicleJPN());
    logger.finest("RETURN updateXCustomerVehicleJPN()");
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
	protected void deleteXCustomerVehicleJPN() throws Exception{
    logger.finest("ENTER deleteXCustomerVehicleJPN()");
         // MDM_TODO: CDKWB0018I Write customized business logic for the extension here.
    logger.finest("RETURN deleteXCustomerVehicleJPN()");
  } 
  
    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * This method is overridden to construct
      * <code>DWLDuplicateKeyException</code> based on XCustomerVehicleJPN
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
    		DSEAAdditionsExtsErrorReasonCode.DUPLICATE_PRIMARY_KEY_XCUSTOMERVEHICLEJPN,
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
     * An instance of <code>XCustomerVehicleJPNResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XCustomerVehicleJPNResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XCustomerVehicleJPNResultSetProcessor();
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    @Override
    protected Class<XCustomerVehicleJPNInquiryData> provideQueryInterfaceClass() throws BObjQueryException {
        return XCustomerVehicleJPNInquiryData.class;
    }

}


