
import sys
import os
import gitlab
from sqlalchemy import text
from sqlalchemy import create_engine, select, MetaData, Table, insert
import concurrent.futures
from functools import partial
from gitlab.exceptions import GitlabGetError
import concurrent.futures
import multiprocessing
from datetime import datetime, timedelta
import logging
import time
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
import json

import configparser
config = configparser.ConfigParser()


s_config = """
[GITLAB]
xxxxx
xxxxx

[HGITLAB]
xxxxx
xxxxx

[GITLAB2]
xxxxx
xxxxx

[DATABASE]
xxxxx
xxxxx
"""

config.read_string(s_config)



def main():
    """main function that runs the analyze method based on schedule
    # """

    engine = connectDB()

    # or_code = sys.argv[1]
    # Configure the logger
    log_file_path = 'outputAllOrCode.log'
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)
    file_handler = logging.FileHandler(log_file_path)
    file_handler.setLevel(logging.INFO)
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)
    print("Automatically Mapping Technology and extentions from Repos to DB table")
    logger.info("Automatically Mapping Technology and extentions from Repos to DB table")

    orcode_query = "(select distinct(or_code)\
        from master_orcode mo left join tbl_project_orcode_mapping tpo on(tpo.orcode_id = mo.id) left join projects_master pm\
        on(pm.project_id = tpo.project_id) where mo.is_del != 1 and perspective in ('LINES_OF_CODE', 'COMBINATION') and \
        mo.or_code in (select or_code from master_isg_projects where status != 'Closed'))"
    orcodes = engine.execute(orcode_query)
    orcode_list = [result[0] for result in orcodes]

    for orcode in orcode_list:
        print(f"Now Running for orcode {orcode}")
        mapTechExtensions(engine,orcode,logger)

    print("Script Executed now exiting code")
    logger.info("Script Executed now exiting code")
    exit(0)


def mapTechExtensions(engine,or_code,logger):


    try:
        project_query = text("select git_project_id, path, domain from projects_master where project_id in \
        (select project_id from tbl_project_orcode_mapping where orcode_id in\
        (select id from master_orcode where or_code in (:or_code)))")
        result = engine.execute(project_query, or_code=or_code)
        rows = result.fetchall()

        # Create a metadata object
        metadata = MetaData(bind=engine)

        # Define the tbl_orcode_extension_mapping table
        tbl_orcode_extension_mapping = Table('tbl_orcode_extension_mapping', metadata, autoload=True)
        master_technology_extension_mapping = Table('master_technology_extension_mapping', metadata, autoload=True)
        tbl_extension_autosync_error_log = Table('tbl_extension_autosync_error_log', metadata, autoload=True)
        current_date = datetime.now()
        # Calculate the start date of the week (Monday)
        start_of_week = current_date - timedelta(days=current_date.weekday())
        # Set the activation_date variable
        activation_date = start_of_week.date()
        disabled_extension_query = text("SELECT extension FROM master_disabled_extensions WHERE is_del = 0")
        disabled_extensions = engine.execute(disabled_extension_query)
        by_default_disabled_ext = [result[0] for result in disabled_extensions]
        # by_default_disabled_ext=['.txt','.log','.png','.jpeg','.tmp','.bak','.swp','.dmp']
        official_domain = ['https://gitlab.kpit.com', 'https://h-gitlab.kpit.com', 'https://gitlab2.kpit.com']

        for row in rows:
            if row:
                git_project_id, path, domain = row[0], row[1], row[2]

                if domain not in official_domain:
                    continue
                # Create a connection
                conn = engine.connect()
                try:
                    gl = connectGit(domain)
                    project = gl.projects.get(git_project_id)
                except Exception as e:
                    if(e.error_message=='404 Project Not Found'):
                        # Insert error log into the tbl_extension_autosync_error_log table
                        stmt = select([tbl_extension_autosync_error_log]).where(
                            (tbl_extension_autosync_error_log.c.or_code == or_code) &
                            (tbl_extension_autosync_error_log.c.git_project_id == git_project_id)
                        )
                        extensionResult = conn.execute(stmt)
                        if not extensionResult.fetchone():
                            stmt = insert(tbl_extension_autosync_error_log).values(
                                git_project_id=git_project_id,
                                or_code=or_code,
                                path=path,
                                domain=domain,
                                description=e.error_message
                            )
                            conn.execute(stmt)
                        extensionResult.close()
                    logger.error(f"{e}")

                # Set a timeout for list_file_extensions_all_branches
                timeout = 300  # 10 minutes in seconds
                # List project repository files
                # all_branch_extensions  = list_file_extensions_all_branches(project)
                try:
                    # Use multiprocessing.Pool to run the function with a timeout
                    with multiprocessing.Pool(processes=1) as pool:
                        result = pool.apply_async(list_file_extensions_all_branches, (project,))
                        all_branch_extensions = result.get(timeout=timeout)

                    # Continue processing with 'all_branch_extensions' as needed
                    print(all_branch_extensions)

                except multiprocessing.TimeoutError:
                    print(f"Timeout occurred for project {git_project_id}. Continuing with the next project.")
                    logger.error(f"Timeout occurred for project {git_project_id}. Continuing with the next project.")
                    # Insert error log into the tbl_extension_autosync_error_log table
                    stmt = select([tbl_extension_autosync_error_log]).where(
                        (tbl_extension_autosync_error_log.c.or_code == or_code) &
                        (tbl_extension_autosync_error_log.c.git_project_id == git_project_id)
                    )
                    extensionResult = conn.execute(stmt)
                    if not extensionResult.fetchone():
                        stmt = insert(tbl_extension_autosync_error_log).values(
                            git_project_id = git_project_id,
                            or_code=or_code,
                            path=path,
                            domain=domain,
                            description="Unable to fetch data from gitlab Timeout Error Occurred"
                        )
                        conn.execute(stmt)
                    extensionResult.close()
                except Exception as e:
                    print(f"An error occurred for project {git_project_id}: {e}")
                    logger.error(f"An error occurred for project {git_project_id}: {e}")


                # with open('D:/CTO Project(Insights)/automateTechnologyExtensionMapping/tecnology.txt', 'r') as file:
                #     TechnologyData = json.load(file)

                with open('/home/hrishikeshp/zdd/automateTechExtMapping/tecnology.txt', 'r') as file:
                    TechnologyData = json.load(file)


                # is_active = 1  # extension should be set as active
                is_active = 0  # by default newly added extension should be set as disabled
                # Insert data into the table
                for extension in all_branch_extensions:
                    name = "Misc Technology"  # Default name if extension is not found
                    type = "Misc Type"
                    for tech_info in TechnologyData:
                        if extension in tech_info['extensions']:
                            name = tech_info['name']
                            type = tech_info['type']
                            break

                    # Check if the combination of or_code and extension already exists
                    stmt = select([tbl_orcode_extension_mapping]).where(
                        (tbl_orcode_extension_mapping.c.or_code == or_code) &
                        (tbl_orcode_extension_mapping.c.extension == extension)
                    )
                    extensionResult = conn.execute(stmt)


                    # Insert into the tbl_orcode_extension_mapping table only if the combination does not exist
                    if not extensionResult.fetchone():
                        # Insert into the tbl_orcode_extension_mapping table
                        if extension in by_default_disabled_ext:
                            stmt = insert(tbl_orcode_extension_mapping).values(
                                or_code=or_code,
                                technology_name=name,
                                extension=extension,
                                is_active=0,
                                activation_date=activation_date,
                                deactivation_date=activation_date
                            )
                            conn.execute(stmt)
                        else:
                            stmt = insert(tbl_orcode_extension_mapping).values(
                                or_code=or_code,
                                technology_name=name,
                                extension=extension,
                                is_active=is_active,
                                activation_date=activation_date
                            )
                            conn.execute(stmt)

                    extensionResult.close()

                    # Check if the extension already exists in master extension table
                    stmt2 = select([master_technology_extension_mapping]).where(
                        (master_technology_extension_mapping.c.extension == extension)
                    )
                    masterTblExtensionResult = conn.execute(stmt2)

                    # Insert into the tbl_orcode_extension_mapping table only if the combination does not exist
                    if not masterTblExtensionResult.fetchone():
                        # Insert into the tbl_orcode_extension_mapping table
                        stmt2 = insert(master_technology_extension_mapping).values(
                            technology_name=name,
                            technology_type=type,
                            extension=extension,
                        )
                        conn.execute(stmt2)

                    masterTblExtensionResult.close()

                # Close the database connection
                conn.close()
                # Print the file extensions
                print("Done For ",path)
                logger.info(f"Done for {path}")
                gl = None
                # for ext in all_branch_extensions:
                    # print(ext)


    except Exception as e:
        print(e)
        logger.error(f"{e} error for or_code{or_code}")

def list_file_extensions_all_branches(project):
    # Get a list of all branch names in the repository
    branches = project.branches.list(get_all=True)
    branches2 = list(map(lambda branch: branch.name, branches))

    max_threads = 10

    # Create a partial function with 'project' as a fixed argument
    # partial_func = partial(list_file_extensions_recursive, project=project)
    partial_func = partial(wrapper_function, project=project)


    try:
        # Create a ThreadPoolExecutor with the specified number of threads
        with concurrent.futures.ThreadPoolExecutor(max_threads) as executor:
            # Map the process_branch function to the branch_names list, running them in parallel
            # results = executor.map(partial_func, branches2)
            results = executor.map(partial_func, branches2)
    except GitlabGetError as e:
        # Handle the GitLab Get Error (HTTP 503) here
        print(f"GitLab server not responding. Error: {e}")
    except Exception as e:
        # Handle other exceptions here
        print(f"An error occurred: {e}")

    all_branch_extension_list = []
    for result in results:
        all_branch_extension_list.extend(result)

    # Remove duplicates and empty strings
    unique_extensions = list(set(all_branch_extension_list))
    if '' in unique_extensions:
        unique_extensions.remove('')

    return unique_extensions

def wrapper_function(branch_name, project):
    try:
        return list_file_extensions_recursive(project, branch_name)
    except GitlabGetError as e:
        # Handle the GitLab Get Error (HTTP 503) specifically for this function
        print(f"GitLab server not responding for branch {branch_name}. Error: {e}")
        return set()  # Return an empty set or handle it as appropriate

def list_file_extensions_recursive(project,branch_name, path=""):
    # Initialize a set to store unique file extensions
    file_extensions = set()

    try:

        # List project repository files and folders for the specified branch
        items = project.repository_tree(path=path, ref=branch_name,get_all=True)

        # Iterate through the files and folders
        for item in items:
            if item["type"] == "blob":
                file_name = item["name"]
                file_extension = os.path.splitext(file_name)[1]
                file_extension = file_extension.lower()
                file_extensions.add(file_extension)
            elif item["type"] == "tree":
                # Recursively traverse into subfolders
                subfolder_path = os.path.join(path, item["name"]).replace("\\", "/")
                subfolder_extensions = list_file_extensions_recursive(project,branch_name,subfolder_path)
                file_extensions.update(subfolder_extensions)

        return file_extensions
    except GitlabGetError as e:
        # Handle the GitLab Get Error (HTTP 503) specifically for this function
        # print(f"GitLab server not responding for branch {branch_name}. Error: {e}")
        raise  # Re-raise the exception to be caught in the wrapper_function
    except Exception as e:
        # Handle other exceptions here
        # print(f"An error occurred for branch {branch_name}: {e}")
        raise  # Re-raise the exception to be caught in the wrapper_function

def connectDB():
    url = config.get('DATABASE', 'engine')
    db = config.get('DATABASE', 'db')
    try:
        engine = create_engine(url + db)
        return engine
    except Exception as ex:
        # print(ex)
        pass


def domain_selector(domain):
    if 'https://gitlab2.kpit.com' == domain:
        return 'GITLAB2'
    if 'https://gitlab.kpit.com' == domain:
        return 'GITLAB'
    if 'https://h-gitlab.kpit.com' == domain:
        return 'HGITLAB'

def connectGit(domain):
    domain_name = domain_selector(domain)
    # print ("domain name",domain_name)
    token = config.get(domain_name, 'private_token')
    url = config.get(domain_name, 'url')
    # print (token,url)
    try:
        gl = gitlab.Gitlab(url, private_token=token)
        return gl
    except Exception as ex:
        # print(ex)
        pass

def newConnectGitFn(domain):
    domain_name = domain_selector(domain)
    # print ("domain name",domain_name)
    token = config.get(domain_name, 'private_token')
    url = config.get(domain_name, 'url')
    # print (token,url)
    try:
        gl = gitlab.Gitlab(url, private_token=token)
        return gl
    except Exception as ex:
        # print(ex)
        pass

def create_table(conn, table_name):     
    sql = f""" CREATE TABLE IF NOT EXISTS {table_name} (                                         
    id integer PRIMARY KEY,                                        
     code text NOT NULL                                     
     ); 
     """
     try:         
        c = conn.cursor()    
        c.execute(sql)     
     except Error as e:         
        print(e)

if __name__ == '__main__':
    main()
