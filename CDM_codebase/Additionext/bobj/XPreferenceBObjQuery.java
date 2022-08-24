
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
 * IBM-MDMWB-1.0-[93b4e3b004aa83a8482a5e26da042486]
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

import com.ibm.daimler.dsea.component.XPreferenceBObj;
import com.ibm.daimler.dsea.component.XPreferenceResultSetProcessor;

import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsComponentID;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsErrorReasonCode;

import com.ibm.daimler.dsea.entityObject.EObjXPreferenceData;
import com.ibm.daimler.dsea.entityObject.XPreferenceInquiryData;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class provides query information for the business object
 * <code>XPreferenceBObj</code>.
 *
 * @generated
 */
public class XPreferenceBObjQuery  extends com.dwl.bobj.query.GenericBObjQuery {

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XPREFERENCE_QUERY = "getXPreference(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XPREFERENCE_HISTORY_QUERY = "getXPreferenceHistory(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XPREFERENCE_BY_LOCATION_GROUP_ID_QUERY = "getXPreferenceByLocationGroupId(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XPREFERENCE_BY_LOCATION_GROUP_ID_HISTORY_QUERY = "getXPreferenceByLocationGroupIdHistory(Object[])";

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XPreferenceBObjQuery.class);
     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XPREFERENCE_ADD = "XPREFERENCE_ADD";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated NOT
      */
     public static final String XPREFERENCE_DELETE = "XPREFERENCE_DELETE";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XPREFERENCE_UPDATE = "XPREFERENCE_UPDATE";


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
    public XPreferenceBObjQuery(String queryName, DWLControl control) {
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
    public XPreferenceBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
        super(persistenceStrategyName, objectToPersist);
    }

	 
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated NOT
     */
	protected void persist() throws Exception{
    logger.finest("ENTER persist()");
    if (logger.isFinestEnabled()) {
   		String infoForLogging="Persistence strategy is " + persistenceStrategyName;
      logger.finest("persist() " + infoForLogging);
        }
    if (persistenceStrategyName.equals(XPREFERENCE_ADD)) {
      addXPreference();
    }else if(persistenceStrategyName.equals(XPREFERENCE_UPDATE)) {
      updateXPreference();
    }else if(persistenceStrategyName.equals(XPREFERENCE_DELETE)) {
      deleteXPreference();
    }
    logger.finest("RETURN persist()");
  }
  
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xpreference data by calling
      * <code>EObjXPreferenceData.createEObjXPreference</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXPreference() throws Exception{
    logger.finest("ENTER addXPreference()");
    
    EObjXPreferenceData theEObjXPreferenceData = (EObjXPreferenceData) DataAccessFactory
      .getQuery(EObjXPreferenceData.class, connection);
    theEObjXPreferenceData.createEObjXPreference(((XPreferenceBObj) objectToPersist).getEObjXPreference());
    logger.finest("RETURN addXPreference()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xpreference data by calling
      * <code>EObjXPreferenceData.updateEObjXPreference</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXPreference() throws Exception{
    logger.finest("ENTER updateXPreference()");
    EObjXPreferenceData theEObjXPreferenceData = (EObjXPreferenceData) DataAccessFactory
      .getQuery(EObjXPreferenceData.class, connection);
    theEObjXPreferenceData.updateEObjXPreference(((XPreferenceBObj) objectToPersist).getEObjXPreference());
    logger.finest("RETURN updateXPreference()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes {0} data by calling <{1}>{2}.{3}{4}</{1}>
   *
     * @throws Exception
     *
     * @generated NOT
     */
	protected void deleteXPreference() throws Exception{
    logger.finest("ENTER deleteXPreference()");
         // MDM_TODO: CDKWB0018I Write customized business logic for the extension here.
    EObjXPreferenceData theEObjXPreferenceData = (EObjXPreferenceData) DataAccessFactory
    	      .getQuery(EObjXPreferenceData.class, connection);
    	    theEObjXPreferenceData.deleteEObjXPreference(((XPreferenceBObj) objectToPersist).getEObjXPreference().getLocationGroupId());
    logger.finest("RETURN deleteXPreference()");
  } 
  
    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * This method is overridden to construct
      * <code>DWLDuplicateKeyException</code> based on XPreference component
      * specific values.
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
    		DSEAAdditionsExtsErrorReasonCode.DUPLICATE_PRIMARY_KEY_XPREFERENCE,
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
     * An instance of <code>XPreferenceResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XPreferenceResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XPreferenceResultSetProcessor();
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    @Override
    protected Class<XPreferenceInquiryData> provideQueryInterfaceClass() throws BObjQueryException {
        return XPreferenceInquiryData.class;
    }

}


