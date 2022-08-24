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
 * IBM-MDMWB-1.0-[9f000abd0c684f1928ad20a8ab92aaaa]
 */

package com.ibm.daimler.dsea.bobj.query;


import com.dwl.base.DWLCommon;
import com.dwl.base.DWLControl;

import com.dwl.bobj.query.BObjQuery;
import com.dwl.bobj.query.Persistence;

import com.dwl.common.globalization.util.ResourceBundleHelper;

import com.ibm.daimler.dsea.bobj.query.XCompanyIdentificationBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XConsentBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XContractDetailsBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XContractDetailsJPNBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XContractRelBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XContractRelJPNBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerRetailerBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerRetailerJPNBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerRetailerRoleBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleAusBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleJPNBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleKORBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleRoleAusBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleRoleBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleRoleJPNBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XCustomerVehicleRoleKORBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XDataSharingBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XDealerRetailerBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XDeleteAuditBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XEpucidTempBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XGurantorCompanyBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XGurantorIndividualBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XMagicRelBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XPreferenceBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XPrivacyAgreementBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XRetailerBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XVRCollapseBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XVehicleAusBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XVehicleAddressBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XVehicleBObjQuery;

import com.ibm.daimler.dsea.bobj.query.XVehicleJPNBObjQuery;
import com.ibm.daimler.dsea.bobj.query.XVehicleKORBObjQuery;
import com.ibm.daimler.dsea.constant.ResourceBundleNames;

/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This factory class provides methods to return the BObjQuery instances
 * relating to the relevant business objects.
 *
 * @generated
 */
public class DSEAAdditionsExtsModuleBObjQueryFactoryImpl  implements DSEAAdditionsExtsModuleBObjQueryFactory, DSEAAdditionsExtsModuleBObjPersistenceFactory {

	private final static String EXCEPTION_QUERYNAME_EMPTY = "Exception_AbstractBObjQuery_QueryNameCannotBeEmpty";
	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(DSEAAdditionsExtsModuleBObjQueryFactoryImpl.class);

    /**
   * <!-- begin-user-doc -->
	 * <!-- end-user-doc -->
   *
     * Default constructor.
     *
     * @generated
     */
    public DSEAAdditionsExtsModuleBObjQueryFactoryImpl() {
        super();
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XPreferenceBObj</code> business object.
      *
      * @return 
      * An instance of <code>XPreferenceBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXPreferenceBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXPreferenceBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXPreferenceBObjQuery(String queryName, DWLControl dwlControl)");
        return new XPreferenceBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XPreferenceBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XPreferenceBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXPreferenceBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XPreferenceBObjQuery(persistenceStrategyName, objectToPersist);
      }
      
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XPrivacyAgreementBObj</code> business object.
      *
      * @return 
      * An instance of <code>XPrivacyAgreementBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXPrivacyAgreementBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXPrivacyAgreementBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXPrivacyAgreementBObjQuery(String queryName, DWLControl dwlControl)");
        return new XPrivacyAgreementBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XPrivacyAgreementBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XPrivacyAgreementBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXPrivacyAgreementBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XPrivacyAgreementBObjQuery(persistenceStrategyName, objectToPersist);
      }
      
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XRetailerBObj</code> business object.
      *
      * @return 
      * An instance of <code>XRetailerBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXRetailerBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXRetailerBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXRetailerBObjQuery(String queryName, DWLControl dwlControl)");
        return new XRetailerBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XRetailerBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XRetailerBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXRetailerBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XRetailerBObjQuery(persistenceStrategyName, objectToPersist);
      }
      
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerRetailerBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerRetailerBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerRetailerBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerRetailerBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerRetailerBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerRetailerBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerRetailerBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerRetailerBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerRetailerBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerRetailerBObjQuery(persistenceStrategyName, objectToPersist);
      }
      
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerRetailerRoleBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerRetailerRoleBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerRetailerRoleBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerRetailerRoleBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerRetailerRoleBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerRetailerRoleBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerRetailerRoleBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerRetailerRoleBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerRetailerRoleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerRetailerRoleBObjQuery(persistenceStrategyName, objectToPersist);
      }
      
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XVehicleBObj</code> business object.
      *
      * @return 
      * An instance of <code>XVehicleBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXVehicleBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXVehicleBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXVehicleBObjQuery(String queryName, DWLControl dwlControl)");
        return new XVehicleBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XVehicleBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XVehicleBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXVehicleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XVehicleBObjQuery(persistenceStrategyName, objectToPersist);
      }
      
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleBObjQuery(persistenceStrategyName, objectToPersist);
      }
      
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleRoleBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleRoleBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleRoleBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleRoleBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleRoleBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleRoleBObjQuery(queryName, dwlControl);
    }
    
     /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleRoleBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleRoleBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleRoleBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCompanyIdentificationBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCompanyIdentificationBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCompanyIdentificationBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCompanyIdentificationBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCompanyIdentificationBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCompanyIdentificationBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCompanyIdentificationBObj</code> business
      * object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCompanyIdentificationBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCompanyIdentificationBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCompanyIdentificationBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XContractDetailsBObj</code> business object.
      *
      * @return 
      * An instance of <code>XContractDetailsBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXContractDetailsBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXContractDetailsBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXContractDetailsBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContractDetailsBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XContractDetailsBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContractDetailsBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXContractDetailsBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XContractDetailsBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XGurantorIndividualBObj</code> business object.
      *
      * @return 
      * An instance of <code>XGurantorIndividualBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXGurantorIndividualBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXGurantorIndividualBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXGurantorIndividualBObjQuery(String queryName, DWLControl dwlControl)");
        return new XGurantorIndividualBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XGurantorIndividualBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XGurantorIndividualBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXGurantorIndividualBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XGurantorIndividualBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XGurantorCompanyBObj</code> business object.
      *
      * @return 
      * An instance of <code>XGurantorCompanyBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXGurantorCompanyBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXGurantorCompanyBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXGurantorCompanyBObjQuery(String queryName, DWLControl dwlControl)");
        return new XGurantorCompanyBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XGurantorCompanyBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XGurantorCompanyBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXGurantorCompanyBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XGurantorCompanyBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XDealerRetailerBObj</code> business object.
      *
      * @return 
      * An instance of <code>XDealerRetailerBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXDealerRetailerBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXDealerRetailerBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXDealerRetailerBObjQuery(String queryName, DWLControl dwlControl)");
        return new XDealerRetailerBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XDealerRetailerBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XDealerRetailerBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXDealerRetailerBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XDealerRetailerBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XMagicRelBObj</code> business object.
      *
      * @return 
      * An instance of <code>XMagicRelBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXMagicRelBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXMagicRelBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXMagicRelBObjQuery(String queryName, DWLControl dwlControl)");
        return new XMagicRelBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XMagicRelBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XMagicRelBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXMagicRelBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XMagicRelBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XConsentBObj</code> business object.
      *
      * @return 
      * An instance of <code>XConsentBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXConsentBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXConsentBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXConsentBObjQuery(String queryName, DWLControl dwlControl)");
        return new XConsentBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XConsentBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XConsentBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXConsentBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XConsentBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XContractRelBObj</code> business object.
      *
      * @return 
      * An instance of <code>XContractRelBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXContractRelBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXContractRelBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXContractRelBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContractRelBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XContractRelBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContractRelBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXContractRelBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XContractRelBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerRetailerJPNBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerRetailerJPNBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerRetailerJPNBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerRetailerJPNBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerRetailerJPNBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerRetailerJPNBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerRetailerJPNBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerRetailerJPNBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerRetailerJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerRetailerJPNBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XVehicleJPNBObj</code> business object.
      *
      * @return 
      * An instance of <code>XVehicleJPNBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXVehicleJPNBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXVehicleJPNBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXVehicleJPNBObjQuery(String queryName, DWLControl dwlControl)");
        return new XVehicleJPNBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XVehicleJPNBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XVehicleJPNBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXVehicleJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XVehicleJPNBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleJPNBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleJPNBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleJPNBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleJPNBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleJPNBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleJPNBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleJPNBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleJPNBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleJPNBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleRoleJPNBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleRoleJPNBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleRoleJPNBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleRoleJPNBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleRoleJPNBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleRoleJPNBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleRoleJPNBObj</code> business
      * object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleRoleJPNBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleRoleJPNBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XDataSharingBObj</code> business object.
      *
      * @return 
      * An instance of <code>XDataSharingBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXDataSharingBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXDataSharingBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXDataSharingBObjQuery(String queryName, DWLControl dwlControl)");
        return new XDataSharingBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XDataSharingBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XDataSharingBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXDataSharingBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XDataSharingBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XVehicleKORBObj</code> business object.
      *
      * @return 
      * An instance of <code>XVehicleKORBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXVehicleKORBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXVehicleKORBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXVehicleKORBObjQuery(String queryName, DWLControl dwlControl)");
        return new XVehicleKORBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XVehicleKORBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XVehicleKORBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXVehicleKORBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XVehicleKORBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleKORBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleKORBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleKORBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleKORBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleKORBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleKORBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleKORBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleKORBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleKORBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleKORBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleRoleKORBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleRoleKORBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleRoleKORBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleRoleKORBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleRoleKORBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleRoleKORBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleRoleKORBObj</code> business
      * object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleRoleKORBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleKORBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleRoleKORBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XEpucidTempBObj</code> business object.
      *
      * @return 
      * An instance of <code>XEpucidTempBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXEpucidTempBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXEpucidTempBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXEpucidTempBObjQuery(String queryName, DWLControl dwlControl)");
        return new XEpucidTempBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XEpucidTempBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XEpucidTempBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXEpucidTempBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XEpucidTempBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XContractDetailsJPNBObj</code> business object.
      *
      * @return 
      * An instance of <code>XContractDetailsJPNBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXContractDetailsJPNBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXContractDetailsJPNBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXContractDetailsJPNBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContractDetailsJPNBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XContractDetailsJPNBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContractDetailsJPNBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXContractDetailsJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XContractDetailsJPNBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XContractRelJPNBObj</code> business object.
      *
      * @return 
      * An instance of <code>XContractRelJPNBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXContractRelJPNBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXContractRelJPNBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXContractRelJPNBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContractRelJPNBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XContractRelJPNBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContractRelJPNBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXContractRelJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XContractRelJPNBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XVehicleAusBObj</code> business object.
      *
      * @return 
      * An instance of <code>XVehicleAusBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXVehicleAusBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXVehicleAusBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXVehicleAusBObjQuery(String queryName, DWLControl dwlControl)");
        return new XVehicleAusBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XVehicleAusBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XVehicleAusBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXVehicleAusBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XVehicleAusBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleAusBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleAusBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleAusBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleAusBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleAusBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleAusBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleAusBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleAusBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleAusBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleAusBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XCustomerVehicleRoleAusBObj</code> business object.
      *
      * @return 
      * An instance of <code>XCustomerVehicleRoleAusBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXCustomerVehicleRoleAusBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXCustomerVehicleRoleAusBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXCustomerVehicleRoleAusBObjQuery(String queryName, DWLControl dwlControl)");
        return new XCustomerVehicleRoleAusBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XCustomerVehicleRoleAusBObj</code> business
      * object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XCustomerVehicleRoleAusBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleAusBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XCustomerVehicleRoleAusBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XVRCollapseBObj</code> business object.
      *
      * @return 
      * An instance of <code>XVRCollapseBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXVRCollapseBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXVRCollapseBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXVRCollapseBObjQuery(String queryName, DWLControl dwlControl)");
        return new XVRCollapseBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XVRCollapseBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XVRCollapseBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXVRCollapseBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XVRCollapseBObjQuery(persistenceStrategyName, objectToPersist);
      }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * Provides the concrete BObjQuery instance corresponding to the
      * <code>XDeleteAuditBObj</code> business object.
      *
      * @return 
      * An instance of <code>XDeleteAuditBObjQuery</code>.
      *
      * @generated
      */
      public BObjQuery createXDeleteAuditBObjQuery(String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createXDeleteAuditBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
      throw new IllegalArgumentException(ResourceBundleHelper.resolve(
          ResourceBundleNames.COMMON_SERVICES_STRINGS,
          EXCEPTION_QUERYNAME_EMPTY));
        }
    logger.finest("RETURN createXDeleteAuditBObjQuery(String queryName, DWLControl dwlControl)");
        return new XDeleteAuditBObjQuery(queryName, dwlControl);
    }

    /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>XDeleteAuditBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XDeleteAuditBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createXDeleteAuditBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {

        return new XDeleteAuditBObjQuery(persistenceStrategyName, objectToPersist);
      }
      

}


