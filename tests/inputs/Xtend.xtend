/* https://raw.githubusercontent.com/tsaglam/JavaCodeEcorification/master/src/main/java/jce/generators/EFactoryImplementationGenerator.xtend
   with some mods to include ««« inline comments
   */
package jce.generators

import java.io.File
import java.util.List
import jce.properties.EcorificationProperties
import jce.util.PathHelper
import org.eclipse.core.resources.IProject

/**
 * Generator class for the generation of Ecore factory implementation classes.
 * @author Timur Saglam
 */
class EFactoryImplementationGenerator extends ClassGenerator {
	extension PathHelper nameUtil

	/**
	 * Basic constructor, sets the properties.
	 */
	new(EcorificationProperties properties) {
		super(properties)
		nameUtil = new PathHelper('.')
	}

	/**
	 * Creates a Ecore Factory in a package path with a specific name. 
	 */
	def public void create(String path, List<String> packageTypes, IProject project) {
		val currentPackage = path.replace(File.separatorChar, '.') // path to package declaration
		val interfacePackage = currentPackage.cutLastSegment
		val packageName = interfacePackage.getLastSegment.toFirstUpper
		val content = createFactoryContent(currentPackage, packageName, interfacePackage, packageTypes)
		createClass(path, '''«packageName»FactoryImpl.java''', content, project)
		monitor.beginTask(''' Created «packageName»FactoryImpl.java''', 0) // detailed logging
	}

	/**
	 * Creates the content of an Ecore factory.
	 */
	def private String createFactoryContent(String currentPackage, String packageName, String interfacePackage, List<String> packageTypes) '''
		package «currentPackage»;
		
		import org.eclipse.emf.ecore.EClass;
		import org.eclipse.emf.ecore.EObject;
		import org.eclipse.emf.ecore.EPackage;
		import org.eclipse.emf.ecore.impl.EFactoryImpl;
		import org.eclipse.emf.ecore.plugin.EcorePlugin;
		
		import «interfacePackage».«packageName»Factory;
		import «interfacePackage».«packageName»Package;
		«FOR type : packageTypes»
			import «interfacePackage.cutFirstSegment».«type»;
		«ENDFOR»
		
		/**
		 * An implementation of the model <b>Factory</b>.
		 * @generated
		 */
		public class «packageName»FactoryImpl extends EFactoryImpl implements «packageName»Factory {
		    /**
		     * Creates the default factory implementation.
		     * <!-- begin-user-doc -->
		     * <!-- end-user-doc -->
		     * @generated
		     */
		    public static «packageName»Factory init() {
		        try {
		            «packageName»Factory the«packageName»Factory = («packageName»Factory)EPackage.Registry.INSTANCE.getEFactory(«packageName»Package.eNS_URI);
		            if (the«packageName»Factory != null) {
		                return the«packageName»Factory;
		            }
		        }
		        catch (Exception exception) {
		            EcorePlugin.INSTANCE.log(exception);
		        }
		        return new «packageName»FactoryImpl();
		    }
		
		    /**
		     * Creates an instance of the factory.
		     * @generated
		     */
		    public «packageName»FactoryImpl() {
		        super();
		    }
		
		    /**
		     * @generated
		     */
		    @Override
		    public EObject create(EClass eClass) {
		        switch (eClass.getClassifierID()) {
					«FOR type : packageTypes»
						case «packageName»Package.«constantName(type)»: return create«type»();
					«ENDFOR»
					default:
					    throw new IllegalArgumentException("The class '" + eClass.getName() + "' is not a valid classifier");
					     }
					 }
			
			«FOR type : packageTypes SEPARATOR blankLine»
				«createFactoryMethod(type)»
			«ENDFOR»
			
			/**
			 * @generated
			 */
			public «packageName»Package get«packageName»Package() {
			return («packageName»Package)getEPackage();
			}
		
		    /**
		     * @deprecated
		     * @generated
		     */
		    @Deprecated
		    public static «packageName»Package getPackage() {
		        return «packageName»Package.eINSTANCE;
		    }
		    
		} //«packageName»FactoryImpl
	'''

	/**
	 * Creates the content of an Ecore factory method.
	 */
	def private String createFactoryMethod(String className) '''
		/**
		 * @generated
		 */
		public «className» create«className»() {
			return new «className»(); // origin code instance
		}	
	'''

	/**
	 * Makes a constant name out of a type name (MyType => MY_TYPE, ABCTest => ABC_TEST)
	 */
	def private String constantName(String typeName) {
		var constantName = "" // empty result string
		var wasLowerCase = true // last word was lower case
		for (String word : typeName.split("(?=\\p{Upper})")) { // iterate over every word
			if(containsLowerCase(word) || wasLowerCase) { // if has or comes after lower case letter.
				constantName += '_' // add separator
			}
			constantName += word.toUpperCase()
			wasLowerCase = containsLowerCase(word)
		}
		return constantName.substring(1)
	}

	/**
	 * Checks whether a String contains lower case characters. 
	 */
	def private boolean containsLowerCase(String string) {
		return !string.equals(string.toUpperCase())
	}
}
