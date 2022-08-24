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
 * IBM-MDMWB-1.0-[5480db23a58faf15429b2d286415734a]
 */

package com.ibm.daimler.dsea.bobj.query;
 
import com.dwl.base.DWLCommon;
import com.dwl.bobj.query.Persistence;
/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * Interface through which instances of concrete implementation of
 * <code>Persistence</code> can be created for DSEAAdditionsExts module.
 *
 * @generated
 */
public interface DSEAAdditionsExtsModuleBObjPersistenceFactory {

    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * @generated
     */
	public final static String BOBJ_PERSISTENCE_FACTORY = "DSEAAdditionsExts.BObjPersistenceFactory";

    
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
      * An instance of <code>XPreferenceBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXPreferenceBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XPrivacyAgreementBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXPrivacyAgreementBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XRetailerBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXRetailerBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerRetailerBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerRetailerBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerRetailerRoleBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerRetailerRoleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XVehicleBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXVehicleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleRoleBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCompanyIdentificationBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCompanyIdentificationBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XContractDetailsBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXContractDetailsBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XGurantorIndividualBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXGurantorIndividualBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XGurantorCompanyBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXGurantorCompanyBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XDealerRetailerBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXDealerRetailerBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XMagicRelBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXMagicRelBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XConsentBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXConsentBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XContractRelBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXContractRelBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerRetailerJPNBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerRetailerJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XVehicleJPNBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXVehicleJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleJPNBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleRoleJPNBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XDataSharingBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXDataSharingBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XVehicleKORBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXVehicleKORBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleKORBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleKORBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleRoleKORBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleKORBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XEpucidTempBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXEpucidTempBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XContractDetailsJPNBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXContractDetailsJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XContractRelJPNBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXContractRelJPNBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XVehicleAusBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXVehicleAusBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleAusBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleAusBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XCustomerVehicleRoleAusBObjQuery</code>, which is a
      * concrete implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXCustomerVehicleRoleAusBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XVRCollapseBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXVRCollapseBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

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
      * An instance of <code>XDeleteAuditBObjQuery</code>, which is a concrete
      * implementation of <code>Persistence</code> interface.      
      *
      * @generated
      */
      public Persistence createXDeleteAuditBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist);

}

