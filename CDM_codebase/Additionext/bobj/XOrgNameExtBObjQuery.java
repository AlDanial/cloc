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
 * IBM-MDMWB-1.0-[bc1af58ffe5eba03a1bfc74ab8097c84]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.coreParty.bobj.query.OrganizationNameBObjQuery;

import com.dwl.tcrm.coreParty.component.TCRMOrganizationNameBObj;

import com.ibm.daimler.dsea.component.XOrgNameBObjExt;
import com.ibm.daimler.dsea.component.XOrgNameExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXOrgNameExtData;
import com.ibm.daimler.dsea.entityObject.XOrgNameExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>OrganizationNameBObjQuery</code> class.
 *
 * @generated
 */
public class XOrgNameExtBObjQuery extends OrganizationNameBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XOrgNameExtBObjQuery.class);
   
   /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Default constructor.
     *
     * @param queryName
     *     The name of the query.
     * @param control
     *     The control object.
     *
     * @generated
     */
    public XOrgNameExtBObjQuery(String queryName, DWLControl control) {
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
    public XOrgNameExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
        super(persistenceStrategyName, objectToPersist);
    }


    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
     @SuppressWarnings("rawtypes")
    protected Class provideQueryInterfaceClass()  throws BObjQueryException  {
        return XOrgNameExtInquiryData.class;
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
    if (logger.isFinestEnabled()) {
      String infoForLogging=" Extension with fields added to DB table";
      logger.finest("persist() " + infoForLogging);
    }
    if (objectToPersist instanceof XOrgNameBObjExt) {
      String infoForLogging="persist() instanceof XOrgNameBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(ORGANIZATION_NAME_ADD)) {
        addXOrgName();
      }else if(persistenceStrategyName.equals(ORGANIZATION_NAME_UPDATE)) {
        updateXOrgName();
      }else if(persistenceStrategyName.equals(ORGANIZATION_NAME_DELETE)) {
        deleteXOrgName();
      }else {
        super.persist();
      }
    } else {
      if (logger.isFinestEnabled()) {
        String infoForLogging="Call super.persist()";
      logger.finest("persist() " + infoForLogging);
      }
      super.persist();
    }		
    
    logger.finest("RETURN persist()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Inserts xorgname data by calling
      * <code>EObjXOrgNameExtData.createEObjXOrgName</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXOrgName() throws Exception{
    logger.finest("ENTER addXOrgName()");
    EObjXOrgNameExtData theEObjXOrgNameExtData = (EObjXOrgNameExtData) DataAccessFactory
      .getQuery(EObjXOrgNameExtData.class, connection);
 		theEObjXOrgNameExtData.createEObjXOrgNameExt(
 		                                 ((TCRMOrganizationNameBObj) objectToPersist).getEObjOrganizationName(),
 		                                 ((XOrgNameBObjExt) objectToPersist).getEObjXOrgNameExt());
    logger.finest("RETURN addXOrgName()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xorgname data by calling
      * <code>EObjXOrgNameExtData.updateEObjXOrgName</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXOrgName() throws Exception{
    logger.finest("ENTER updateXOrgName()");
    EObjXOrgNameExtData theEObjXOrgNameExtData = (EObjXOrgNameExtData) DataAccessFactory
      .getQuery(EObjXOrgNameExtData.class, connection);
 		theEObjXOrgNameExtData.updateEObjXOrgNameExt(
 		                                 ((TCRMOrganizationNameBObj) objectToPersist).getEObjOrganizationName(),
 		                                 ((XOrgNameBObjExt) objectToPersist).getEObjXOrgNameExt());
    logger.finest("RETURN updateXOrgName()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xorgname data by calling
      * <code>EObjXOrgNameExtData.deleteEObjXOrgName</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXOrgName() throws Exception{
    logger.finest("ENTER deleteXOrgName()");
    Long id = ((XOrgNameBObjExt) objectToPersist).getEObjOrganizationName().getOrgNameIdPK();
    EObjXOrgNameExtData theEObjXOrgNameExtData = (EObjXOrgNameExtData) DataAccessFactory
      .getQuery(EObjXOrgNameExtData.class, connection);
    theEObjXOrgNameExtData.deleteEObjXOrgNameExt(id);
    logger.finest("RETURN deleteXOrgName()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XOrgNameExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XOrgNameExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XOrgNameExtResultSetProcessor();
    }    


    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * @generated
     */
    protected String getSQLStatement() throws BObjQueryException {
        String sql = super.getSQLStatement();
        if (sql != null) {
            return sql;
        }
        return getSQLStatement(super.provideQueryInterfaceClass());
    }
}


