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
 * IBM-MDMWB-1.0-[716089315407b1a8d5b2f860c46f9415]
 */


package com.ibm.daimler.dsea.bobj.query;

import com.dwl.tcrm.coreParty.bobj.query.PartyModuleBObjQueryFactoryImpl;


import com.dwl.base.DWLCommon;
import com.dwl.base.DWLControl;

import com.dwl.bobj.query.BObjQuery;
import com.dwl.bobj.query.Persistence;


/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * The <code>XPartyModuleBObjQueryFactoryImpl</code> is the factory class that
 * provides methods to return the BObjQuery instances corresponding to the
 * business objects.
 *
 * @see com.dwl.tcrm.coreParty.bobj.query.PartyModuleBObjQueryFactory
 * 
 * @generated
 */
 public class XPartyModuleBObjQueryFactoryImpl extends PartyModuleBObjQueryFactoryImpl {
	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XPartyModuleBObjQueryFactoryImpl.class);

    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @generated
     */
    public XPartyModuleBObjQueryFactoryImpl() {
        super();
    }
    
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMPersonBObj</code> business object.
     *
     * @return 
     * An instance of <code>XPersonExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createPersonBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createPersonBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createPersonBObjQuery(String queryName, DWLControl dwlControl)");
        return new XPersonExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMPersonBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XPersonExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createPersonBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createPersonBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XPersonExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMOrganizationBObj</code> business object.
     *
     * @return 
     * An instance of <code>XOrgExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createOrganizationBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createOrganizationBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createOrganizationBObjQuery(String queryName, DWLControl dwlControl)");
        return new XOrgExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMOrganizationBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XOrgExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createOrganizationBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createOrganizationBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XOrgExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMAddressBObj</code> business object.
     *
     * @return 
     * An instance of <code>XAddressExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createAddressBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createAddressBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createAddressBObjQuery(String queryName, DWLControl dwlControl)");
        return new XAddressExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMAddressBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XAddressExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createAddressBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createAddressBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XAddressExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMPartyAddressBObj</code> business object.
     *
     * @return 
     * An instance of <code>XAddressGroupExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createPartyAddressBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createPartyAddressBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createPartyAddressBObjQuery(String queryName, DWLControl dwlControl)");
        return new XAddressGroupExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMPartyAddressBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XAddressGroupExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createPartyAddressBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createPartyAddressBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XAddressGroupExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMPartyContactMethodBObj</code> business object.
     *
     * @return 
     * An instance of <code>XContactMethodGroupExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createPartyContactMethodBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createPartyContactMethodBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createPartyContactMethodBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContactMethodGroupExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMPartyContactMethodBObj</code> business
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
      * An instance of <code>XContactMethodGroupExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createPartyContactMethodBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createPartyContactMethodBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XContactMethodGroupExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMPartyRelationshipBObj</code> business object.
     *
     * @return 
     * An instance of <code>XContactRelExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createPartyRelationshipBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createPartyRelationshipBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createPartyRelationshipBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContactRelExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMPartyRelationshipBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContactRelExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createPartyRelationshipBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createPartyRelationshipBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XContactRelExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
    /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMPersonNameBObj</code> business object.
     *
     * @return 
     * An instance of <code>XPersonNameExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createPersonNameBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createPersonNameBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createPersonNameBObjQuery(String queryName, DWLControl dwlControl)");
        return new XPersonNameExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMPersonNameBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XPersonNameExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createPersonNameBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createPersonNameBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XPersonNameExtBObjQuery(persistenceStrategyName, objectToPersist);
      }

      /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMOrganizationNameBObj</code> business object.
     *
     * @return 
     * An instance of <code>XOrgNameExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createOrganizationNameBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createOrganizationNameBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createOrganizationNameBObjQuery(String queryName, DWLControl dwlControl)");
        return new XOrgNameExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMOrganizationNameBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XOrgNameExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createOrganizationNameBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createOrganizationNameBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XOrgNameExtBObjQuery(persistenceStrategyName, objectToPersist);
      }

      /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMPartyIdentificationBObj</code> business object.
     *
     * @return 
     * An instance of <code>XIdentifierExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createPartyIdentificationBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createPartyIdentificationBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createPartyIdentificationBObjQuery(String queryName, DWLControl dwlControl)");
        return new XIdentifierExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMPartyIdentificationBObj</code> business
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
      * An instance of <code>XIdentifierExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createPartyIdentificationBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createPartyIdentificationBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XIdentifierExtBObjQuery(persistenceStrategyName, objectToPersist);
      }

      /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMContactMethodBObj</code> business object.
     *
     * @return 
     * An instance of <code>XContactMethodExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createContactMethodBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createContactMethodBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createContactMethodBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContactMethodExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMContactMethodBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContactMethodExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createContactMethodBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createContactMethodBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XContactMethodExtBObjQuery(persistenceStrategyName, objectToPersist);
      }

      /** 
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the concrete BObjQuery instance corresponding to the
     * <code>TCRMAdminContEquivBObj</code> business object.
     *
     * @return 
     * An instance of <code>XContEquivExtBObjQuery</code>.
     *
     * @generated
     */
      public BObjQuery createAdminContEquivBObjQuery (String queryName, DWLControl dwlControl) {
    logger.finest("ENTER createAdminContEquivBObjQuery(String queryName, DWLControl dwlControl)");
        if ((queryName == null) || queryName.trim().equals("")) {
            throw new IllegalArgumentException(
                    "Query Name cannot be empty or null.");
        }
    logger.finest("RETURN createAdminContEquivBObjQuery(String queryName, DWLControl dwlControl)");
        return new XContEquivExtBObjQuery(queryName, dwlControl);
    }

      /** 
      * <!-- begin-user-doc -->
      * <!-- end-user-doc -->
      *
      * This method returns an object of type <code>Persistence</code>
      * corresponding to <code>TCRMAdminContEquivBObj</code> business object.
      *
      * @param persistenceStrategyName
      * The persistence strategy name.  This parameter indicates the type of
      * database action to be taken such as addition, update or deletion of
      * records.
      * @param objectToPersist
      * The business object to be persisted.
      *      
      * @return 
      * An instance of <code>XContEquivExtBObjQuery</code>.
      *
      * @generated
      */
      public Persistence createAdminContEquivBObjPersistence(String persistenceStrategyName, DWLCommon objectToPersist) {
    logger.finest("ENTER createAdminContEquivBObjPersistence(String persistenceStrategyName, DWLControl dwlControl)");
   	
        return new XContEquivExtBObjQuery(persistenceStrategyName, objectToPersist);
      }   
}

