
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
 * IBM-MDMWB-1.0-[e42e22b246235c3c5e8487db6fbd9566]
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

import com.ibm.daimler.dsea.component.XCustomerVehicleAusBObj;
import com.ibm.daimler.dsea.component.XCustomerVehicleAusResultSetProcessor;

import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsComponentID;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsErrorReasonCode;

import com.ibm.daimler.dsea.entityObject.EObjXCustomerVehicleAusData;
import com.ibm.daimler.dsea.entityObject.XCustomerVehicleAusInquiryData;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class provides query information for the business object
 * <code>XCustomerVehicleAusBObj</code>.
 *
 * @generated
 */
public class XCustomerVehicleAusBObjQuery  extends com.dwl.bobj.query.GenericBObjQuery {

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_AUS_QUERY = "getXCustomerVehicleAus(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_AUS_HISTORY_QUERY = "getXCustomerVehicleAusHistory(Object[])";

	/**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_AUS_BY_PARTY_ID_QUERY = "getAllXCustomerVehicleAusByPartyId(Object[])";

    /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_AUS_BY_PARTY_ID_HISTORY_QUERY = "getAllXCustomerVehicleAusByPartyIdHistory(Object[])";

    /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_AUS_BY_VEHICLE_ID_QUERY = "getAllXCustomerVehicleAusByVehicleId(Object[])";

    /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String ALL_XCUSTOMER_VEHICLE_AUS_BY_VEHICLE_ID_HISTORY_QUERY = "getAllXCustomerVehicleAusByVehicleIdHistory(Object[])";

  /**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XCustomerVehicleAusBObjQuery.class);
     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_AUS_ADD = "XCUSTOMER_VEHICLE_AUS_ADD";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_AUS_DELETE = "XCUSTOMER_VEHICLE_AUS_DELETE";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCUSTOMER_VEHICLE_AUS_UPDATE = "XCUSTOMER_VEHICLE_AUS_UPDATE";


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
    public XCustomerVehicleAusBObjQuery(String queryName, DWLControl control) {
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
    public XCustomerVehicleAusBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
    if (persistenceStrategyName.equals(XCUSTOMER_VEHICLE_AUS_ADD)) {
      addXCustomerVehicleAus();
    }else if(persistenceStrategyName.equals(XCUSTOMER_VEHICLE_AUS_UPDATE)) {
      updateXCustomerVehicleAus();
    }else if(persistenceStrategyName.equals(XCUSTOMER_VEHICLE_AUS_DELETE)) {
      deleteXCustomerVehicleAus();
    }
    logger.finest("RETURN persist()");
  }
  
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xcustomervehicleaus data by calling
      * <code>EObjXCustomerVehicleAusData.createEObjXCustomerVehicleAus</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXCustomerVehicleAus() throws Exception{
    logger.finest("ENTER addXCustomerVehicleAus()");
    
    EObjXCustomerVehicleAusData theEObjXCustomerVehicleAusData = (EObjXCustomerVehicleAusData) DataAccessFactory
      .getQuery(EObjXCustomerVehicleAusData.class, connection);
    theEObjXCustomerVehicleAusData.createEObjXCustomerVehicleAus(((XCustomerVehicleAusBObj) objectToPersist).getEObjXCustomerVehicleAus());
    logger.finest("RETURN addXCustomerVehicleAus()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcustomervehicleaus data by calling
      * <code>EObjXCustomerVehicleAusData.updateEObjXCustomerVehicleAus</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXCustomerVehicleAus() throws Exception{
    logger.finest("ENTER updateXCustomerVehicleAus()");
    EObjXCustomerVehicleAusData theEObjXCustomerVehicleAusData = (EObjXCustomerVehicleAusData) DataAccessFactory
      .getQuery(EObjXCustomerVehicleAusData.class, connection);
    theEObjXCustomerVehicleAusData.updateEObjXCustomerVehicleAus(((XCustomerVehicleAusBObj) objectToPersist).getEObjXCustomerVehicleAus());
    logger.finest("RETURN updateXCustomerVehicleAus()");
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
	protected void deleteXCustomerVehicleAus() throws Exception{
    logger.finest("ENTER deleteXCustomerVehicleAus()");
         // MDM_TODO: CDKWB0018I Write customized business logic for the extension here.
    logger.finest("RETURN deleteXCustomerVehicleAus()");
  } 
  
    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * This method is overridden to construct
      * <code>DWLDuplicateKeyException</code> based on XCustomerVehicleAus
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
    		DSEAAdditionsExtsErrorReasonCode.DUPLICATE_PRIMARY_KEY_XCUSTOMERVEHICLEAUS,
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
     * An instance of <code>XCustomerVehicleAusResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XCustomerVehicleAusResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XCustomerVehicleAusResultSetProcessor();
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    @Override
    protected Class<XCustomerVehicleAusInquiryData> provideQueryInterfaceClass() throws BObjQueryException {
        return XCustomerVehicleAusInquiryData.class;
    }

}


