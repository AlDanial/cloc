
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
 * IBM-MDMWB-1.0-[aaab46ff0ab54223c68415ddf6cbbb02]
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

import com.ibm.daimler.dsea.component.XContractRelJPNBObj;
import com.ibm.daimler.dsea.component.XContractRelJPNResultSetProcessor;

import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsComponentID;
import com.ibm.daimler.dsea.constant.DSEAAdditionsExtsErrorReasonCode;

import com.ibm.daimler.dsea.entityObject.EObjXContractRelJPNData;
import com.ibm.daimler.dsea.entityObject.XContractRelJPNInquiryData;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class provides query information for the business object
 * <code>XContractRelJPNBObj</code>.
 *
 * @generated
 */
public class XContractRelJPNBObjQuery  extends com.dwl.bobj.query.GenericBObjQuery {

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCONTRACT_REL_JPN_QUERY = "getXContractRelJPN(Object[])";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCONTRACT_REL_JPN_HISTORY_QUERY = "getXContractRelJPNHistory(Object[])";

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XContractRelJPNBObjQuery.class);
     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCONTRACT_REL_JPN_ADD = "XCONTRACT_REL_JPN_ADD";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCONTRACT_REL_JPN_DELETE = "XCONTRACT_REL_JPN_DELETE";

     /**
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * @generated
      */
     public static final String XCONTRACT_REL_JPN_UPDATE = "XCONTRACT_REL_JPN_UPDATE";


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
    public XContractRelJPNBObjQuery(String queryName, DWLControl control) {
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
    public XContractRelJPNBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
    if (persistenceStrategyName.equals(XCONTRACT_REL_JPN_ADD)) {
      addXContractRelJPN();
    }else if(persistenceStrategyName.equals(XCONTRACT_REL_JPN_UPDATE)) {
      updateXContractRelJPN();
    }else if(persistenceStrategyName.equals(XCONTRACT_REL_JPN_DELETE)) {
      deleteXContractRelJPN();
    }
    logger.finest("RETURN persist()");
  }
  
 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xcontractreljpn data by calling
      * <code>EObjXContractRelJPNData.createEObjXContractRelJPN</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXContractRelJPN() throws Exception{
    logger.finest("ENTER addXContractRelJPN()");
    
    EObjXContractRelJPNData theEObjXContractRelJPNData = (EObjXContractRelJPNData) DataAccessFactory
      .getQuery(EObjXContractRelJPNData.class, connection);
    theEObjXContractRelJPNData.createEObjXContractRelJPN(((XContractRelJPNBObj) objectToPersist).getEObjXContractRelJPN());
    logger.finest("RETURN addXContractRelJPN()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xcontractreljpn data by calling
      * <code>EObjXContractRelJPNData.updateEObjXContractRelJPN</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXContractRelJPN() throws Exception{
    logger.finest("ENTER updateXContractRelJPN()");
    EObjXContractRelJPNData theEObjXContractRelJPNData = (EObjXContractRelJPNData) DataAccessFactory
      .getQuery(EObjXContractRelJPNData.class, connection);
    theEObjXContractRelJPNData.updateEObjXContractRelJPN(((XContractRelJPNBObj) objectToPersist).getEObjXContractRelJPN());
    logger.finest("RETURN updateXContractRelJPN()");
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
	protected void deleteXContractRelJPN() throws Exception{
    logger.finest("ENTER deleteXContractRelJPN()");
         // MDM_TODO: CDKWB0018I Write customized business logic for the extension here.
    logger.finest("RETURN deleteXContractRelJPN()");
  } 
  
    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * This method is overridden to construct
      * <code>DWLDuplicateKeyException</code> based on XContractRelJPN component
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
    		DSEAAdditionsExtsErrorReasonCode.DUPLICATE_PRIMARY_KEY_XCONTRACTRELJPN,
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
     * An instance of <code>XContractRelJPNResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XContractRelJPNResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XContractRelJPNResultSetProcessor();
    }

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    @Override
    protected Class<XContractRelJPNInquiryData> provideQueryInterfaceClass() throws BObjQueryException {
        return XContractRelJPNInquiryData.class;
    }

}


