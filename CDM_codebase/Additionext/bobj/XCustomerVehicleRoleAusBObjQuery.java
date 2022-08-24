
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
 * IBM-MDMWB-1.0-[3d2851d19f7546470a77c501d08cafb7]
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

import com.ibm.daimler.dsea.component.XCustomerVehicleRoleAusBObj;
import com.ibm.daimler.dsea.component.XCustomerVehicleRoleAusResultSetProcessor;

import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsComponentID;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsErrorReasonCode;

import com.ibm.daimler.dsea.entityObject.EObjXCustomerVehicleRoleAusData;
import com.ibm.daimler.dsea.entityObject.XCustomerVehicleRoleAusInquiryData;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class provides query information for the business object
 * <code>XCustomerVehicleRoleAusBObj</code>.
 *
 * @generated
 */
public class XCustomerVehicleRoleAusBObjQuery  extends com.dwl.bobj.query.GenericBObjQuery {

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_ROLE_AUS_QUERY = "getXCustomerVehicleRoleAus(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_ROLE_AUS_HISTORY_QUERY = "getXCustomerVehicleRoleAusHistory(Object[])";

	/**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_VEHICLE_ROLE_AUS_BY_CUSTOMER_VEHICLE_ID_QUERY = "getAllVehicleRoleAusByCustomerVehicleId(Object[])";

    /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_VEHICLE_ROLE_AUS_BY_CUSTOMER_VEHICLE_ID_HISTORY_QUERY = "getAllVehicleRoleAusByCustomerVehicleIdHistory(Object[])";

  /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_ROLE_AUS_BY_XCUSTOMER_VEHICLE_AUS_QUERY = "getAllXCustomerVehicleRoleAusByXCustomerVehicleAus(Object[])";

    /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_ROLE_AUS_BY_XCUSTOMER_VEHICLE_AUS_HISTORY_QUERY = "getAllXCustomerVehicleRoleAusByXCustomerVehicleAusHistory(Object[])";

  /**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XCustomerVehicleRoleAusBObjQuery.class);
     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_ROLE_AUS_ADD = "XCUSTOMER_VEHICLE_ROLE_AUS_ADD";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_ROLE_AUS_DELETE = "XCUSTOMER_VEHICLE_ROLE_AUS_DELETE";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_ROLE_AUS_UPDATE = "XCUSTOMER_VEHICLE_ROLE_AUS_UPDATE";


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
    public XCustomerVehicleRoleAusBObjQuery(String queryName, DWLControl control) {
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
    public XCustomerVehicleRoleAusBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
    if (persistenceStrategyName.equals(XCUSTOMER_VEHICLE_ROLE_AUS_ADD)) {
      addXCustomerVehicleRoleAus();
    }else if(persistenceStrategyName.equals(XCUSTOMER_VEHICLE_ROLE_AUS_UPDATE)) {
      updateXCustomerVehicleRoleAus();
    }else if(persistenceStrategyName.equals(XCUSTOMER_VEHICLE_ROLE_AUS_DELETE)) {
      deleteXCustomerVehicleRoleAus();
    }
    logger.finest("RETURN persist()");
  }
  
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xcustomervehicleroleaus data by calling
      * <code>EObjXCustomerVehicleRoleAusData.createEObjXCustomerVehicleRoleAus</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXCustomerVehicleRoleAus() throws Exception{
    logger.finest("ENTER addXCustomerVehicleRoleAus()");
    
    EObjXCustomerVehicleRoleAusData theEObjXCustomerVehicleRoleAusData = (EObjXCustomerVehicleRoleAusData) DataAccessFactory
      .getQuery(EObjXCustomerVehicleRoleAusData.class, connection);
    theEObjXCustomerVehicleRoleAusData.createEObjXCustomerVehicleRoleAus(((XCustomerVehicleRoleAusBObj) objectToPersist).getEObjXCustomerVehicleRoleAus());
    logger.finest("RETURN addXCustomerVehicleRoleAus()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcustomervehicleroleaus data by calling
      * <code>EObjXCustomerVehicleRoleAusData.updateEObjXCustomerVehicleRoleAus</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXCustomerVehicleRoleAus() throws Exception{
    logger.finest("ENTER updateXCustomerVehicleRoleAus()");
    EObjXCustomerVehicleRoleAusData theEObjXCustomerVehicleRoleAusData = (EObjXCustomerVehicleRoleAusData) DataAccessFactory
      .getQuery(EObjXCustomerVehicleRoleAusData.class, connection);
    theEObjXCustomerVehicleRoleAusData.updateEObjXCustomerVehicleRoleAus(((XCustomerVehicleRoleAusBObj) objectToPersist).getEObjXCustomerVehicleRoleAus());
    logger.finest("RETURN updateXCustomerVehicleRoleAus()");
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
	protected void deleteXCustomerVehicleRoleAus() throws Exception{
    logger.finest("ENTER deleteXCustomerVehicleRoleAus()");
         // MDM_TODO: CDKWB0018I Write customized business logic for the extension here.
    logger.finest("RETURN deleteXCustomerVehicleRoleAus()");
  } 
  
    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * This method is overridden to construct
      * <code>DWLDuplicateKeyException</code> based on XCustomerVehicleRoleAus
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
    		DSEAAdditionsExtsErrorReasonCode.DUPLICATE_PRIMARY_KEY_XCUSTOMERVEHICLEROLEAUS,
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
     * An instance of <code>XCustomerVehicleRoleAusResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XCustomerVehicleRoleAusResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XCustomerVehicleRoleAusResultSetProcessor();
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    @Override
    protected Class<XCustomerVehicleRoleAusInquiryData> provideQueryInterfaceClass() throws BObjQueryException {
        return XCustomerVehicleRoleAusInquiryData.class;
    }

}


