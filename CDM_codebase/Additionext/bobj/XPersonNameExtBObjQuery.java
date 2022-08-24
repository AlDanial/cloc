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
 * IBM-MDMWB-1.0-[03e3279fda0d6bee74f4094e8843ccba]
 */

package com.ibm.daimler.dsea.bobj.query;




import com.dwl.base.DWLControl;
import com.dwl.bobj.query.BObjQueryException;
import com.dwl.base.DWLCommon;


import com.dwl.base.db.DataAccessFactory;

import com.dwl.base.interfaces.IGenericResultSetProcessor;

import com.dwl.tcrm.coreParty.bobj.query.PersonNameBObjQuery;

import com.dwl.tcrm.coreParty.component.TCRMPersonNameBObj;

import com.ibm.daimler.dsea.component.XPersonNameBObjExt;
import com.ibm.daimler.dsea.component.XPersonNameExtResultSetProcessor;

import com.ibm.daimler.dsea.entityObject.EObjXPersonNameExtData;
import com.ibm.daimler.dsea.entityObject.XPersonNameExtInquiryData;





/**
 * <!-- begin-user-doc -->
 * <!-- end-user-doc -->
 *
 * This class extends the <code>PersonNameBObjQuery</code> class.
 *
 * @generated
 */
public class XPersonNameExtBObjQuery extends PersonNameBObjQuery {

	/**
    * <!-- begin-user-doc -->
	  * <!-- end-user-doc -->
    * @generated 
    */
	 private final static com.dwl.base.logging.IDWLLogger logger = com.dwl.base.logging.DWLLoggerManager.getLogger(XPersonNameExtBObjQuery.class);
   
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
    public XPersonNameExtBObjQuery(String queryName, DWLControl control) {
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
    public XPersonNameExtBObjQuery(String persistenceStrategyName, DWLCommon objectToPersist) {
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
        return XPersonNameExtInquiryData.class;
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
    if (objectToPersist instanceof XPersonNameBObjExt) {
      String infoForLogging="persist() instanceof XPersonNameBObjExt";
      logger.finest("persist() " + infoForLogging);
      if (persistenceStrategyName.equals(PERSON_NAME_ADD)) {
        addXPersonName();
      }else if(persistenceStrategyName.equals(PERSON_NAME_UPDATE)) {
        updateXPersonName();
      }else if(persistenceStrategyName.equals(PERSON_NAME_DELETE)) {
        deleteXPersonName();
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
      * Inserts xpersonname data by calling
      * <code>EObjXPersonNameExtData.createEObjXPersonName</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void addXPersonName() throws Exception{
    logger.finest("ENTER addXPersonName()");
    EObjXPersonNameExtData theEObjXPersonNameExtData = (EObjXPersonNameExtData) DataAccessFactory
      .getQuery(EObjXPersonNameExtData.class, connection);
 		theEObjXPersonNameExtData.createEObjXPersonNameExt(
 		                                 ((TCRMPersonNameBObj) objectToPersist).getEObjPersonName(),
 		                                 ((XPersonNameBObjExt) objectToPersist).getEObjXPersonNameExt());
    logger.finest("RETURN addXPersonName()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
      * Updates xpersonname data by calling
      * <code>EObjXPersonNameExtData.updateEObjXPersonName</code>
     *
     * @throws Exception
     *
     * @generated
     */
	protected void updateXPersonName() throws Exception{
    logger.finest("ENTER updateXPersonName()");
    EObjXPersonNameExtData theEObjXPersonNameExtData = (EObjXPersonNameExtData) DataAccessFactory
      .getQuery(EObjXPersonNameExtData.class, connection);
 		theEObjXPersonNameExtData.updateEObjXPersonNameExt(
 		                                 ((TCRMPersonNameBObj) objectToPersist).getEObjPersonName(),
 		                                 ((XPersonNameBObjExt) objectToPersist).getEObjXPersonNameExt());
    logger.finest("RETURN updateXPersonName()");
  }

 	/**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     * 
      * Deletes xpersonname data by calling
      * <code>EObjXPersonNameExtData.deleteEObjXPersonName</code>
   *
     * @throws Exception
     *
     * @generated
     */
	protected void deleteXPersonName() throws Exception{
    logger.finest("ENTER deleteXPersonName()");
    Long id = ((XPersonNameBObjExt) objectToPersist).getEObjPersonName().getPersonNameIdPK();
    EObjXPersonNameExtData theEObjXPersonNameExtData = (EObjXPersonNameExtData) DataAccessFactory
      .getQuery(EObjXPersonNameExtData.class, connection);
    theEObjXPersonNameExtData.deleteEObjXPersonNameExt(id);
    logger.finest("RETURN deleteXPersonName()");
    } 



    /**
     * <!-- begin-user-doc -->
     * <!-- end-user-doc -->
     *
     * Provides the result set processor that is used to populate the business
     * object.
     *
     * @return
     * An instance of <code>XPersonNameExtResultSetProcessor</code>.
     *
     * @see com.dwl.bobj.query.AbstractBObjQuery#provideResultSetProcessor()
     * @see com.ibm.daimler.dsea.component.XPersonNameExtResultSetProcessor
     *
     * @generated
     */
    protected IGenericResultSetProcessor provideResultSetProcessor()
            throws BObjQueryException {

        return new XPersonNameExtResultSetProcessor();
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


