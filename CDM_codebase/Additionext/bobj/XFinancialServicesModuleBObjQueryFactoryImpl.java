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
 * IBM-MDMWB-1.0-[efc02789ccb1bbedefb5221d2c440200]
 */


package com.ibm.daimler.dsea.bobj.query;

import com.dwl.tcrm.financial.bobj.query.FinancialServicesModuleBObjQueryFactoryImpl;


import com.dwl.base.DWLCommon;
import com.dwl.base.DWLControl;

import com.dwl.bobj.query.BObjQuery;
import com.dwl.bobj.query.Persistence;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * The <code>XFinancialServicesModuleBObjQueryFactoryImpl</code> is the factory
 * class that provides methods to return the BObjQuery instances corresponding
 * to the business objects.
 *
 * @see com.dwl.tcrm.financial.bobj.query.FinancialServicesModuleBObjQueryFactory
 * 
 * @generated
 */
 public class XFinancialServicesModuleBObjQueryFactoryImpl extends FinancialServicesModuleBObjQueryFactoryImpl {
	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XFinancialServicesModuleBObjQueryFactoryImpl.class);

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @generated
     */
    public XFinancialServicesModuleBObjQueryFactoryImpl() {
        super();
    }
    
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMContractBObj</code> business object.
     *
     * @return 
     * An instance of <code>XContractExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createContractBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createContractBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createContractBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContractExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMContractBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContractExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createContractBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createContractBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XContractExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMContractPartyRoleBObj</code> business object.
     *
     * @return 
     * An instance of <code>XContractRoleExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createContractPartyRoleBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createContractPartyRoleBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createContractPartyRoleBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContractRoleExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMContractPartyRoleBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContractRoleExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createContractPartyRoleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createContractPartyRoleBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XContractRoleExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
}

