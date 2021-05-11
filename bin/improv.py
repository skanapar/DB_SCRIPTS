#!/bin/env python

##################################################################################################
#  Name:        improv                                                                           #
#  Author:      Randy Johnson                                                                    #
#  Description: Validates 11g RAC database and service names against provisioning plan.          #
#                                                                                                #
#  Usage: improv [options]                                                                       #
#                                                                                                #
#  options:                                                                                      #
#    -h, --help     show this help message and exit                                              #
#    -d             generate a detailed report provisioned service names                         #
#    -e             export the provisioning plan to improv-export.csv                            #
#    -g             generate commands to provision database resources                            #
#    -i             import provisioning plan from improv.csv                                     #
#    -p             probe Running databases for memory & config parameters                       #
#    -r             replay the results of the last execution                                     #
#    -s             strict compliance. Instance Number to Node must also match                   #
#    -t TRACELEVEL  print runtime trace information. Levels include 0, 1, 2                      #
#                                                                                                #
# History:                                                                                       #
#                                                                                                #
# Date       Ver. Who              Change Description                                            #
# ---------- ---- ---------------- ------------------------------------------------------------- #
# 06/27/2012 1.00 Randy Johnson    Initial release.                                              #
# 07/03/2012 1.10 Randy Johnson    Internal documentation added.                                 #
##################################################################################################


# --------------------------------
# Import external Python modules
# --------------------------------
import pickle as pickle
import traceback

from configparser      import SafeConfigParser
from datetime          import datetime
from decimal           import Decimal
from optparse          import OptionParser
from os.path           import exists
from os.path           import basename
from os.path           import dirname
from os                import environ
from os                import linesep
from sys               import exit
from sys               import argv
from sys               import stdout
from sys               import exc_info
from subprocess        import Popen
from subprocess        import PIPE
from subprocess        import STDOUT
from subprocess        import call
from string            import find
from string            import split
from string            import join
from string            import lower
from string            import upper


# ----------------------------
# Function/Class definitions
# ----------------------------

# Def  : formatExceptionInfo()
# Desc : Format and print Python stack trace
# Args : maxTBlevel (default 5). Levels of the call stack.
# Retn : cla=name of exception class, exc=details of exception, 
#        trbk=traceback info (call stack)
#---------------------------------------------------------------------------
def formatExceptionInfo(maxTBlevel=5):
  cla, exc, trbk = exc_info()
  excName = cla.__name__
  try:
    excArgs = exc.__dict__["args"]
  except KeyError:
    excArgs = "<no args>"
  excTb = traceback.format_tb(trbk, maxTBlevel)

  print(excName, excArgs)
  for line in excTb:
    print(line)
  return(excName, excArgs, excTb)
# End formatExceptionInfo()

# Def  : ReadConfig()
# Desc : Reads the configuration file (improv.ini) and stores
#        the section, key=value in a nested dictionary of 
#        dictionaries data structure.
# Args : 
# Retn : ProvisionedDD, ProvSchemeDD
#        ProvisionedDD:
#        A nested dictionary of dictionary structure where
#        each outer dictionary is keyed on the db_unique_name,
#        and each inner dictionary is the key value pairs for 
#        that database in the improv.ini file, 
#        db_cache_size=nnn for example.
#        ProvisionedDD:
#        A nested dictionary of dictionary structure where
#        each outer dictionary is keyed on the db_unique_name
#        and contains a concise provisioning plan for the 
#        database according to the provisioning flags in the 
#        improv.ini file, db, node, P|A|F, and state=enabled|disabled
#---------------------------------------------------------------------------
def ReadConfig():
  ProvisionedDD = {}

  try:
    DatabaseList = Config.sections()
    for ConfKey in DatabaseList:
      DbUniqueName            = Config.get(ConfKey, 'db_unique_name')
      DbName                  = Config.get(ConfKey, 'db_name')
      Username                = Config.get(ConfKey, 'user_name')
      Password                = Config.get(ConfKey, 'password')
      Host                    = Config.get(ConfKey, 'host')
      Port                    = Config.get(ConfKey, 'port')
      ServiceName             = Config.get(ConfKey, 'service_name')
      PgaAggregateTarget      = Config.get(ConfKey, 'pga_aggregate_target')
      DbCacheSize             = Config.get(ConfKey, 'db_cache_size')
      SharedPoolSize          = Config.get(ConfKey, 'shared_pool_size')
      StreamsPoolSize         = Config.get(ConfKey, 'streams_pool_size')
      LargePoolSize           = Config.get(ConfKey, 'large_pool_size')
      JavaPoolSize            = Config.get(ConfKey, 'java_pool_size')
      SgaMaxSize              = Config.get(ConfKey, 'sga_max_size')
      SgaTarget               = Config.get(ConfKey, 'sga_target')
      MemoryMaxTarget         = Config.get(ConfKey, 'memory_max_target')
      MemoryTarget            = Config.get(ConfKey, 'memory_target')
      TotalStorage            = Config.get(ConfKey, 'total_storage')
      DatafileBytes           = Config.get(ConfKey, 'datafile_bytes')
      TempfileBytes           = Config.get(ConfKey, 'tempfile_bytes')
      ControlfileBytes        = Config.get(ConfKey, 'controlfile_bytes')
      RedofileBytes           = Config.get(ConfKey, 'redofile_bytes')
      Node1                   = Config.get(ConfKey, 'node1')
      Node2                   = Config.get(ConfKey, 'node2')
      Node3                   = Config.get(ConfKey, 'node3')
      Node4                   = Config.get(ConfKey, 'node4')
      Node5                   = Config.get(ConfKey, 'node5')
      Node6                   = Config.get(ConfKey, 'node6')
      Node7                   = Config.get(ConfKey, 'node7')
      Node8                   = Config.get(ConfKey, 'node8')
    
      ConfigDict = {
       'db_unique_name'       : DbUniqueName,
       'db_name'              : DbName,
       'user_name'            : Username,
       'password'             : Password,
       'host'                 : Host,
       'port'                 : Port,
       'service_name'         : ServiceName,
       'password'             : Password,
       'pga_aggregate_target' : PgaAggregateTarget,
       'db_cache_size'        : DbCacheSize,
       'shared_pool_size'     : SharedPoolSize,
       'streams_pool_size'    : StreamsPoolSize,
       'large_pool_size'      : LargePoolSize,
       'java_pool_size'       : JavaPoolSize,
       'sga_max_size'         : SgaMaxSize,
       'sga_target'           : SgaTarget,
       'memory_max_target'    : MemoryMaxTarget,
       'memory_target'        : MemoryTarget,
       'total_storage'        : TotalStorage,
       'datafile_bytes'       : DatafileBytes,
       'tempfile_bytes'       : TempfileBytes,
       'controlfile_bytes'    : ControlfileBytes,
       'redofile_bytes'       : RedofileBytes,
       'node1'                : Node1,
       'node2'                : Node2,
       'node3'                : Node3,
       'node4'                : Node4,
       'node5'                : Node5,
       'node6'                : Node6,
       'node7'                : Node7,
       'node8'                : Node8
      }
      ProvisionedDD[DbUniqueName] = ConfigDict
  except:
    formatExceptionInfo()
    print("Error reading key/value pairs from: " + ImprovIni)
    exit(1)

  ProvSchemeDict = {}
  ProvSchemeDD   = {}
  for DbKey in list(ProvisionedDD.keys()):
    DbUniqueName = ProvisionedDD[DbKey]['db_unique_name']
    ProvSchemeDict = {
      'node1' : '',
      'node2' : '',
      'node3' : '',
      'node4' : '',
      'node5' : '',
      'node6' : '',
      'node7' : '',
      'node8' : '',
    }
    InstId = 0
    for NodeId in range(1,8):
      NodeId       = str(NodeId)
      ProvKey      = 'node' + NodeId
      ProvFlag     = str.upper(ProvisionedDD[DbKey][ProvKey])   # 'P', 'A', 'F'

      NodeName = GetNodeName(NodeId)
      if (NodeName == 0):
        NodeName = ''

      DbUniqueName = ProvisionedDD[DbKey]['db_unique_name']
      DbName       = ProvisionedDD[DbKey]['db_name']

      if (ProvFlag == 'P' or ProvFlag == 'A' or ProvFlag == 'F'):
        InstId += 1
        InstName = DbName + str(InstId)
        if (ProvFlag == 'P' or ProvFlag == 'A'):
          ProvSchemeDict[ProvKey] = DbUniqueName + ',' + InstName + ',' + NodeName + ',enabled' + ',' + ProvFlag
        else:
          if (ProvFlag == 'F'):
            ProvSchemeDict[ProvKey] = DbUniqueName + ',' + InstName + ',' + NodeName + ',disabled' + ',' + ProvFlag

    ProvSchemeDD[DbKey] = ProvSchemeDict

  return(ProvisionedDD, ProvSchemeDD)
# End ReadConfig()

# Def  : ImportPlan()
# Desc : Loads up the provisioning settings from the improv.csv file,
#        presumably generated from the Provisioning Spreadsheet.
# Args : ImpFilename (improv.csv)
# Retn : ImpDD:
#        A nested dictionary of dictionary structure where the outer 
#        dictionary is keyed on the db_unique_name and each inner 
#        dictionary contains key = value pairs from the imported csv 
#        file.
#---------------------------------------------------------------------------
def ImportPlan(ImpFilename):
  Impfile = open(ImpFilename)
  ImpfileContents = Impfile.readlines()
  ImpDict = {}
  ImpDD   = {}

  # For example: pauatatl,pauat,2147483648,1073741824,2902458368,0,0,0,70307872768,,P,A,,,,,
  for line in ImpfileContents:
    idx = line.find('#')
    if (idx < 0):
      if (line.count(',') == 15):
        db_unique_name,db_name,pga_aggregate_target,sga_max_size,sga_target,memory_max_target, \
        memory_target,total_storage,node1,node2,node3,node4,node5,node6,node7,node8 = line.split(',')

        db_unique_name       = db_unique_name.strip()       
        db_name              = db_name.strip()              
        pga_aggregate_target = pga_aggregate_target.strip() 
        sga_max_size         = sga_max_size.strip()         
        sga_target           = sga_target.strip()           
        memory_max_target    = memory_max_target.strip()    
        memory_target        = memory_target.strip()        
        total_storage        = total_storage.strip()        
        node1                = node1.strip()                
        node2                = node2.strip()                
        node3                = node3.strip()                
        node4                = node4.strip()                
        node5                = node5.strip()                
        node6                = node6.strip()                
        node7                = node7.strip()                
        node8                = node8.strip()                

        if (db_unique_name != ''):
          # Convert Gigabytes to Bytes and round up/down
          if (pga_aggregate_target != ''):
            pga_aggregate_target           = str(round(Decimal(pga_aggregate_target) * 1024 * 1024 * 1024))

          if (sga_max_size != ''):
            sga_max_size                   = str(round(Decimal(sga_max_size)         * 1024 * 1024 * 1024))

          if (sga_target != ''):                                                     
            sga_target                     = str(round(Decimal(sga_target)           * 1024 * 1024 * 1024))

          if (memory_max_target != ''):                                              
            memory_max_target              = str(round(Decimal(memory_max_target)    * 1024 * 1024 * 1024))

          if (memory_target != ''):                                                  
            memory_target                  = str(round(Decimal(memory_target)        * 1024 * 1024 * 1024))

          if (total_storage != ''):                                                  
            total_storage                  = str(round(Decimal(total_storage)        * 1024 * 1024 * 1024))
          
          # Trim off trailing .0's
          pga_aggregate_target = pga_aggregate_target[0:pga_aggregate_target.find('.')]
          sga_max_size         = sga_max_size[0:sga_max_size.find('.')]         
          sga_target           = sga_target[0:sga_target.find('.')]           
          memory_max_target    = memory_max_target[0:memory_max_target.find('.')]    
          memory_target        = memory_target[0:memory_target.find('.')]        
          total_storage        = total_storage[0:total_storage.find('.')]        
          
          ImpDict = {
           'db_unique_name'           : db_unique_name,
           'db_name'                  : db_name,
           'pga_aggregate_target'     : pga_aggregate_target,
           'sga_max_size'             : sga_max_size,
           'sga_target'               : sga_target,
           'memory_max_target'        : memory_max_target,
           'memory_target'            : memory_target,
           'total_storage'            : total_storage,
           'node1'                    : node1,
           'node2'                    : node2,
           'node3'                    : node3,
           'node4'                    : node4,
           'node5'                    : node5,
           'node6'                    : node6,
           'node7'                    : node7,
           'node8'                    : node8
          }
          ImpDD[db_unique_name] = ImpDict
  return(ImpDD)
# End ImportPlan()


# Def  : MergeRunningConfig()
# Desc : Creates file improv-merge_running.ini containing a merge of the 
#        key=value pairs from the running databases, db_cache_size=nnn 
#        for example, and key=value pairs from the improv.ini file
#        like user_name=sys. The idea being to preserve information from
#        the improv.ini file and saving the memory parameter values 
#        from the actual running datase. This is a useful way to sync-up
#        what is currently running on the system with the improv.ini file.
# Args : ProvisionedDD, RunningDbInfoDD, MergeRunningFilename
# Retn : 
#---------------------------------------------------------------------------
def MergeRunningConfig(ProvisionedDD, RunningDbInfoDD, MergeRunningFilename):
  Mergefile = open(MergeRunningFilename, 'wt')

  try:
    Mergefile.write('[DEFAULT]'                                        +   '\n')
    Mergefile.write('db_unique_name       = '                          +   '\n')
    Mergefile.write('db_name              = '                          +   '\n')
    Mergefile.write('user_name            = sys'                       +   '\n')
    Mergefile.write('password             = SunF10wer'                 +   '\n')
    Mergefile.write('host                 = td01-scan.tnd.us.cbre.net' +   '\n')
    Mergefile.write('port                 = 1521'                      +   '\n')
    Mergefile.write('service_name         = '                          +   '\n')
    Mergefile.write('pga_aggregate_target = 0'                         +   '\n')
    Mergefile.write('db_cache_size        = 0'                         +   '\n')
    Mergefile.write('shared_pool_size     = 0'                         +   '\n')
    Mergefile.write('streams_pool_size    = 0'                         +   '\n')
    Mergefile.write('large_pool_size      = 0'                         +   '\n')
    Mergefile.write('java_pool_size       = 0'                         +   '\n')
    Mergefile.write('sga_max_size         = 0'                         +   '\n')
    Mergefile.write('sga_target           = 0'                         +   '\n')
    Mergefile.write('memory_max_target    = 0'                         +   '\n')
    Mergefile.write('memory_target        = 0'                         +   '\n')
    Mergefile.write('total_storage        = 0'                         +   '\n')
    Mergefile.write('datafile_bytes       = 0'                         +   '\n')
    Mergefile.write('tempfile_bytes       = 0'                         +   '\n')
    Mergefile.write('controlfile_bytes    = 0'                         +   '\n')
    Mergefile.write('redofile_bytes       = 0'                         +   '\n')
    Mergefile.write('node1                = '                          +   '\n')
    Mergefile.write('node2                = '                          +   '\n')
    Mergefile.write('node3                = '                          +   '\n')
    Mergefile.write('node4                = '                          +   '\n')
    Mergefile.write('node5                = '                          +   '\n')
    Mergefile.write('node6                = '                          +   '\n')
    Mergefile.write('node7                = '                          +   '\n')
    Mergefile.write('node8                = '                          + '\n\n')
    
    for DbKey in sorted(RunningDbInfoDD.keys()):
      Mergefile.write('[' + RunningDbInfoDD[DbKey]['db_unique_name'] + ']'                         +   '\n')
      Mergefile.write('db_unique_name       = ' + RunningDbInfoDD[DbKey]['db_unique_name']         +   '\n')
      Mergefile.write('db_name              = ' + RunningDbInfoDD[DbKey]['db_name']                +   '\n')
    
      if (DbKey in list(ProvisionedDD.keys())):
        if ('user_name' in list(ProvisionedDD[DbKey].keys()) and ProvisionedDD[DbKey]['user_name'] != ''):
          Mergefile.write('user_name            = ' + ProvisionedDD[DbKey]['user_name']             +   '\n')
        else:
          Mergefile.write('user_name            = \n')
    
        if ('password' in list(ProvisionedDD[DbKey].keys()) and ProvisionedDD[DbKey]['password'] != ''):
          Mergefile.write('password             = ' + ProvisionedDD[DbKey]['password']             +   '\n')
        else:
          Mergefile.write('password             = \n')
    
        if ('host' in list(ProvisionedDD[DbKey].keys()) and ProvisionedDD[DbKey]['host'] != ''):
          Mergefile.write('host                 = ' + ProvisionedDD[DbKey]['host']             +   '\n')
        else:
          Mergefile.write('host                 = \n')
    
        if ('port' in list(ProvisionedDD[DbKey].keys()) and ProvisionedDD[DbKey]['port'] != ''):
          Mergefile.write('port                 = ' + ProvisionedDD[DbKey]['port']             +   '\n')
        else:
          Mergefile.write('port                 = \n')
    
        if ('service_name' in list(ProvisionedDD[DbKey].keys()) and ProvisionedDD[DbKey]['service_name'] != ''):
          Mergefile.write('service_name         = ' + ProvisionedDD[DbKey]['service_name']             +   '\n')
        else:
          Mergefile.write('service_name         = ' + RunningDbInfoDD[DbKey]['db_unique_name']         +   '\n')
    
        Mergefile.write('db_cache_size        = ' + RunningDbInfoDD[DbKey]['db_cache_size']          +   '\n')
        Mergefile.write('shared_pool_size     = ' + RunningDbInfoDD[DbKey]['shared_pool_size']       +   '\n')
        Mergefile.write('streams_pool_size    = ' + RunningDbInfoDD[DbKey]['streams_pool_size']      +   '\n')
        Mergefile.write('large_pool_size      = ' + RunningDbInfoDD[DbKey]['large_pool_size']        +   '\n')
        Mergefile.write('java_pool_size       = ' + RunningDbInfoDD[DbKey]['java_pool_size']         +   '\n')
        Mergefile.write('sga_max_size         = ' + RunningDbInfoDD[DbKey]['sga_max_size']           +   '\n')
        Mergefile.write('sga_target           = ' + RunningDbInfoDD[DbKey]['sga_target']             +   '\n')
        Mergefile.write('memory_max_target    = ' + RunningDbInfoDD[DbKey]['memory_max_target']      +   '\n')
        Mergefile.write('memory_target        = ' + RunningDbInfoDD[DbKey]['memory_target']          +   '\n')
        Mergefile.write('datafile_bytes       = ' + RunningDbInfoDD[DbKey]['datafile_bytes']         +   '\n')
        Mergefile.write('tempfile_bytes       = ' + RunningDbInfoDD[DbKey]['tempfile_bytes']         +   '\n')
        Mergefile.write('controlfile_bytes    = ' + RunningDbInfoDD[DbKey]['controlfile_bytes']      +   '\n')
        Mergefile.write('redofile_bytes       = ' + RunningDbInfoDD[DbKey]['redofile_bytes']         +   '\n')
        Mergefile.write('db_name              = ' + RunningDbInfoDD[DbKey]['db_name']                +   '\n')
        Mergefile.write('total_storage        = ' + RunningDbInfoDD[DbKey]['total_storage']          +   '\n')
    
        for i in range(1,9):
          if ('node' + str(i) in list(ProvisionedDD[DbKey].keys()) and ProvisionedDD[DbKey]['node' + str(i)] != ''):
            Mergefile.write('node'+ str(i) + '                = ' + ProvisionedDD[DbKey]['node' + str(i)]             +   '\n')
          else:
            Mergefile.write('node'+ str(i) + '                = \n')
        Mergefile.write('\n')
      else:
          Mergefile.write('user_name            = \n')
          Mergefile.write('password             = \n')
          Mergefile.write('host                 = \n')
          Mergefile.write('port                 = \n')
          Mergefile.write('service_name         = ' + RunningDbInfoDD[DbKey]['db_name'] + '\n')
          Mergefile.write('pga_aggregate_target = \n')
          Mergefile.write('db_cache_size        = \n')
          Mergefile.write('shared_pool_size     = \n')
          Mergefile.write('streams_pool_size    = \n')
          Mergefile.write('large_pool_size      = \n')
          Mergefile.write('java_pool_size       = \n')
          Mergefile.write('sga_max_size         = \n')
          Mergefile.write('sga_target           = \n')
          Mergefile.write('memory_max_target    = \n')
          Mergefile.write('memory_target        = \n')
          Mergefile.write('datafile_bytes       = \n')
          Mergefile.write('tempfile_bytes       = \n')
          Mergefile.write('controlfile_bytes    = \n')
          Mergefile.write('redofile_bytes       = \n')
          Mergefile.write('total_storage        = \n')
          Mergefile.write('node1                = \n')
          Mergefile.write('node2                = \n')
          Mergefile.write('node3                = \n')
          Mergefile.write('node4                = \n')
          Mergefile.write('node5                = \n')
          Mergefile.write('node6                = \n')
          Mergefile.write('node7                = \n')
          Mergefile.write('node8                = \n\n')
    Mergefile.close()
  except:
    formatExceptionInfo()
    print('Error writing to new configuration file: ' +  MergeRunningFilename)
    print('Continuing...')
  
  return
# End MergeRunningConfig()

# Def  : MergeImportedConfig()
# Desc : Merges key=value pairs from the improv.csv file with information
#        in the current improv.ini file. This is useful for updating the 
#        improv.ini file with fresh output from the Provisioning 
#        Spreadsheet.
# Args : ProvisionedDD, ImpDD, MergeImportedFilename
# Retn :
#---------------------------------------------------------------------------
def MergeImportedConfig(ProvisionedDD, ImpDD, MergeImportedFilename):
  Mergefile = open(MergeImportedFilename, 'wt')

  try:
    # Write Default Stanza
    Mergefile.write('[DEFAULT]'                                          +   '\n')
    Mergefile.write('db_name                = '                          +   '\n')
    Mergefile.write('user_name              = sys'                       +   '\n')
    Mergefile.write('password               = SunF10wer'                 +   '\n')
    Mergefile.write('host                   = td01-scan.tnd.us.cbre.net' +   '\n')
    Mergefile.write('port                   = 1521'                      +   '\n')
    Mergefile.write('service_name           = '                          +   '\n')
    Mergefile.write('pga_aggregate_target   = 0'                         +   '\n')
    Mergefile.write('db_cache_size          = 0'                         +   '\n')
    Mergefile.write('shared_pool_size       = 0'                         +   '\n')
    Mergefile.write('streams_pool_size      = 0'                         +   '\n')
    Mergefile.write('large_pool_size        = 0'                         +   '\n')
    Mergefile.write('java_pool_size         = 0'                         +   '\n')
    Mergefile.write('sga_max_size           = 0'                         +   '\n')
    Mergefile.write('sga_target             = 0'                         +   '\n')
    Mergefile.write('memory_max_target      = 0'                         +   '\n')
    Mergefile.write('memory_target          = 0'                         +   '\n')
    Mergefile.write('total_storage          = 0'                         +   '\n')
    Mergefile.write('datafile_bytes         = 0'                         +   '\n')
    Mergefile.write('tempfile_bytes         = 0'                         +   '\n')
    Mergefile.write('controlfile_bytes      = 0'                         +   '\n')
    Mergefile.write('redofile_bytes         = 0'                         +   '\n')
    Mergefile.write('node1                  = '                          +   '\n')
    Mergefile.write('node2                  = '                          +   '\n')
    Mergefile.write('node3                  = '                          +   '\n')
    Mergefile.write('node4                  = '                          +   '\n')
    Mergefile.write('node5                  = '                          +   '\n')
    Mergefile.write('node6                  = '                          +   '\n')
    Mergefile.write('node7                  = '                          +   '\n')
    Mergefile.write('node8                  = '                          + '\n\n')
    
    for DbKey in sorted(ImpDD.keys()):
      if (DbKey in list(ProvisionedDD.keys())):
        # if there is a match between the improv.ini and the improv.csv file (from the spreadsheet) then merge
        # the settings giving preference to the improv.csv parameters. Use improv.ini parameters for things 
        # that arent captured in the spreadsheet.
        Mergefile.write('[' + ImpDD[DbKey]['db_unique_name'] + ']'                                    +   '\n')
        Mergefile.write('db_unique_name       = ' + ImpDD[DbKey]['db_unique_name']                    +   '\n')
        Mergefile.write('db_name              = ' + ImpDD[DbKey]['db_name']                           +   '\n')
    
        if ('user_name' in list(ProvisionedDD[DbKey].keys())):
          if (ProvisionedDD[DbKey]['user_name'] != ''):
            Mergefile.write('user_name            = ' + ProvisionedDD[DbKey]['user_name']             +   '\n')
    
        if ('password' in list(ProvisionedDD[DbKey].keys())):
          if (ProvisionedDD[DbKey]['password'] != ''):
            Mergefile.write('password             = ' + ProvisionedDD[DbKey]['password']              +   '\n')
    
        if ('host' in list(ProvisionedDD[DbKey].keys())):
          if (ProvisionedDD[DbKey]['host'] != ''):
            Mergefile.write('host                 = ' + ProvisionedDD[DbKey]['host']                  +   '\n')
    
        if ('port'  in list(ProvisionedDD[DbKey].keys())):
          if (ProvisionedDD[DbKey]['port'] != ''):
            Mergefile.write('port                 = ' + ProvisionedDD[DbKey]['port']                  +   '\n')
    
        if ('service_name' in list(ProvisionedDD[DbKey].keys())):
          if (ProvisionedDD[DbKey]['service_name'] != ''):
            Mergefile.write('service_name         = ' + ProvisionedDD[DbKey]['service_name']          +   '\n')
    
        Mergefile.write('db_cache_size        = ' + ProvisionedDD[DbKey]['db_cache_size']             +   '\n')
        Mergefile.write('shared_pool_size     = ' + ProvisionedDD[DbKey]['shared_pool_size']          +   '\n')
        Mergefile.write('streams_pool_size    = ' + ProvisionedDD[DbKey]['streams_pool_size']         +   '\n')
        Mergefile.write('large_pool_size      = ' + ProvisionedDD[DbKey]['large_pool_size']           +   '\n')
        Mergefile.write('java_pool_size       = ' + ProvisionedDD[DbKey]['java_pool_size']            +   '\n')
        
        Mergefile.write('sga_max_size         = ' + ImpDD[DbKey]['sga_max_size']                      +   '\n')
        Mergefile.write('sga_target           = ' + ImpDD[DbKey]['sga_target']                        +   '\n')
        Mergefile.write('memory_max_target    = ' + ImpDD[DbKey]['memory_max_target']                 +   '\n')
        Mergefile.write('memory_target        = ' + ImpDD[DbKey]['memory_target']                     +   '\n')
        Mergefile.write('pga_aggregate_target = ' + ImpDD[DbKey]['pga_aggregate_target']              +   '\n')
        
        Mergefile.write('total_storage        = ' + ProvisionedDD[DbKey]['total_storage']             +   '\n')
        Mergefile.write('datafile_bytes       = ' + ProvisionedDD[DbKey]['datafile_bytes']            +   '\n')
        Mergefile.write('tempfile_bytes       = ' + ProvisionedDD[DbKey]['tempfile_bytes']            +   '\n')
        Mergefile.write('controlfile_bytes    = ' + ProvisionedDD[DbKey]['controlfile_bytes']         +   '\n')
        Mergefile.write('redofile_bytes       = ' + ProvisionedDD[DbKey]['redofile_bytes']            +   '\n')
        
        Mergefile.write('node1                = ' + ImpDD[DbKey]['node1']                             +   '\n')
        Mergefile.write('node2                = ' + ImpDD[DbKey]['node2']                             +   '\n')
        Mergefile.write('node3                = ' + ImpDD[DbKey]['node3']                             +   '\n')
        Mergefile.write('node4                = ' + ImpDD[DbKey]['node4']                             +   '\n')
        Mergefile.write('node5                = ' + ImpDD[DbKey]['node5']                             +   '\n')
        Mergefile.write('node6                = ' + ImpDD[DbKey]['node6']                             +   '\n')
        Mergefile.write('node7                = ' + ImpDD[DbKey]['node7']                             +   '\n')
        Mergefile.write('node8                = ' + ImpDD[DbKey]['node8']                             + '\n\n')
      else:
        # if there is no entry in the improv.ini for this database just set as follows...
        Mergefile.write('[' + ImpDD[DbKey]['db_unique_name'] + ']'                                    +   '\n')
        Mergefile.write('db_unique_name       = ' + ImpDD[DbKey]['db_unique_name']                    +   '\n')
        Mergefile.write('db_name              = ' + ImpDD[DbKey]['db_name']                           +   '\n')
        Mergefile.write('sga_max_size         = ' + ImpDD[DbKey]['sga_max_size']                      +   '\n')
        Mergefile.write('sga_target           = ' + ImpDD[DbKey]['sga_target']                        +   '\n')
        Mergefile.write('memory_max_target    = ' + ImpDD[DbKey]['memory_max_target']                 +   '\n')
        Mergefile.write('memory_target        = ' + ImpDD[DbKey]['memory_target']                     +   '\n')
        Mergefile.write('pga_aggregate_target = ' + ImpDD[DbKey]['pga_aggregate_target']              +   '\n')
        Mergefile.write('total_storage        = ' + ImpDD[DbKey]['total_storage']                     +   '\n')
        Mergefile.write('node1                = ' + ImpDD[DbKey]['node1']                             +   '\n')
        Mergefile.write('node2                = ' + ImpDD[DbKey]['node2']                             +   '\n')
        Mergefile.write('node3                = ' + ImpDD[DbKey]['node3']                             +   '\n')
        Mergefile.write('node4                = ' + ImpDD[DbKey]['node4']                             +   '\n')
        Mergefile.write('node5                = ' + ImpDD[DbKey]['node5']                             +   '\n')
        Mergefile.write('node6                = ' + ImpDD[DbKey]['node6']                             +   '\n')
        Mergefile.write('node7                = ' + ImpDD[DbKey]['node7']                             +   '\n')
        Mergefile.write('node8                = ' + ImpDD[DbKey]['node8']                             + '\n\n')
    Mergefile.close()
  except:
    formatExceptionInfo()
    print('Error writing to new configuration file: ' +  MergeImportedFilename)
    print('Continuing...')

  return
# End MergeImportedConfig()


# Def  : ExportPlan()
# Desc : This function produces a csv file that can be imported back
#        into the Provisioning Spreadsheet. This allows you to update
#        the spreadsheet with information from the system providing a
#        feedback loop.
# Args : ProvisionedDD:
#        Contains the current (actual provisioning scheme implemented
#        on the cluster.
#        ExpFilename:
#        The name of the export file (improv-export.csv).
# Retn : 
#---------------------------------------------------------------------------
def ExportPlan(ProvisionedDD, ExpFilename):
  CSVfile = open(ExpFilename, 'wt')

  ColumnHeader  = 'db_unique_name,' 
  ColumnHeader += 'db_name,'
  ColumnHeader += 'pga_aggregate_target,'
  ColumnHeader += 'sga_max_size,'
  ColumnHeader += 'sga_target,'
  ColumnHeader += 'memory_max_target,'
  ColumnHeader += 'memory_target,'
  ColumnHeader += 'current_sga_usage,'
  ColumnHeader += 'total_storage,'
  ColumnHeader += 'node1,'
  ColumnHeader += 'node2,'
  ColumnHeader += 'node3,'
  ColumnHeader += 'node4,'
  ColumnHeader += 'node5,'
  ColumnHeader += 'node6,'
  ColumnHeader += 'node7,'
  ColumnHeader += 'node8'

  try:
    CSVfile.write(ColumnHeader + '\n')
    for DbKey in sorted(ProvisionedDD.keys()):
      pga_aggregate_target   = str(round(Decimal(ProvisionedDD[DbKey]['pga_aggregate_target']) / 1024 / 1024 / 1024, 2))
      sga_max_size           = str(round(Decimal(ProvisionedDD[DbKey]['sga_max_size']        ) / 1024 / 1024 / 1024, 2))
      sga_target             = str(round(Decimal(ProvisionedDD[DbKey]['sga_target']          ) / 1024 / 1024 / 1024, 2))
      memory_max_target      = str(round(Decimal(ProvisionedDD[DbKey]['memory_max_target']   ) / 1024 / 1024 / 1024, 2))
      memory_target          = str(round(Decimal(ProvisionedDD[DbKey]['memory_target']       ) / 1024 / 1024 / 1024, 2))
      current_sga_usage      = str(round(Decimal(RunningDbInfoDD[DbKey]['current_sga_usage'] ) / 1024 / 1024 / 1024, 2))
      total_storage          = str(round(Decimal(ProvisionedDD[DbKey]['total_storage']       ) / 1024 / 1024 / 1024, 2))
    
      if (DbKey in list(ProvisionedDD.keys())):
        CSVfile.write(ProvisionedDD[DbKey]['db_unique_name']       + ',')
        CSVfile.write(ProvisionedDD[DbKey]['db_name']              + ',')
        CSVfile.write(pga_aggregate_target                         + ',')
        CSVfile.write(sga_max_size                                 + ',')
        CSVfile.write(sga_target                                   + ',')
        CSVfile.write(memory_max_target                            + ',')
        CSVfile.write(memory_target                                + ',')
        CSVfile.write(current_sga_usage                            + ',')
        CSVfile.write(total_storage                                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node1']                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node2']                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node3']                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node4']                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node5']                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node6']                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node7']                + ',')
        CSVfile.write(ProvisionedDD[DbKey]['node8']                + '\n')
    CSVfile.close()
  except:
    formatExceptionInfo()
    print('Error writing to new configuration file: ' +  ExpFilename)
    print('Continuing...')
  return
# End ExportPlan()


# Def : GetOlsNodesOutput()
# Desc: Runs the olsnodes -n command and returns stdout in a List struct.
# Args: 
# Retn: Olsnodes_Stdout
#       An array (List) of the lines from the stdout from the 
#       'oldnodes -n' command.
#---------------------------------------------------------------------------
def GetOlsNodesOutput():
  Olsnodes_Proc   = Popen([OlsNodes, '-n'], bufsize=1, stdin=PIPE, stdout=PIPE, stderr=STDOUT, shell=False, universal_newlines=True, close_fds=True)
  Olsnodes_Stdout = Olsnodes_Proc.stdout.read()   # # store the output as one long string with embedded newline chrs...
  Olsnodes_Stdout = Olsnodes_Stdout.rstrip()      # remove trailing white spaces from the end of the string...
  return(Olsnodes_Stdout)
# End GetOlsNodesOutput()

# Def : GetRegisteredNodelist()
# Desc: Processes the output from GetOlsNodesOutput() and Capturns the 
#       list of nodes in the cluster (name and id).
# Args: Olsnodes_Stdout
# Retn: RegisteredNodeListOfDict
#       An array (Python List) of dictionaries. Each element in the list
#       contains a dictionary of {NodeName=nnnnnnnn, NodeId=nn}
#---------------------------------------------------------------------------
def GetRegisteredNodes(Olsnodes_Stdout):
  RegisteredNodeDict       = {}
  RegisteredNodeListOfDict = []
  OlsnodesList             = split(Olsnodes_Stdout, '\n')

  for line in OlsnodesList:
    NodeName, NodeId = line.split()
    RegisteredNodeDict = {
      'NodeName' : NodeName,
      'NodeId'   : NodeId
    }
    RegisteredNodeListOfDict.append(RegisteredNodeDict)
  return(RegisteredNodeListOfDict)
# End GetRegisteredNodes()

# Def : GetCrsctlStatPOutput()
# Desc: Runs the crsctl status resource -p command and returns stdout
#       in a List structure.
# Args: 
# Retn: Crsctl_p_Stdout
#       An array (List) of the lines from the stdout from the 
#       'crsctl status resource -p' command.
#---------------------------------------------------------------------------
def GetCrsctlStatPOutput():
  Crsctl_p_Proc   = Popen([CrsCtl, 'status', 'resource', '-p'], bufsize=1, stdin=PIPE, stdout=PIPE, stderr=STDOUT, shell=False, universal_newlines=True, close_fds=True)
  Crsctl_p_Stdout = Crsctl_p_Proc.stdout.read()   # store the stdout in string format...
  Crsctl_p_Stdout = Crsctl_p_Stdout.rstrip()      # remove any trailing white spaces...
  return(Crsctl_p_Stdout)
# End GetCrsctlStatPOutput()

# Def : GetRegisteredDbAttributes()
# Desc: Processes the output from the GetCrsctlStatPOutput function,
#       filters out the cluster database resources and their attributes.
# Args: Crsctl_p_Stdout
# Retn: RegisteredDbDD:
#       Dictionary of dictionaries structure containing registered databases
#       and their cluster attributes. This allows easy lookup by database
#       name later on in the program. The db_unique_name is the value that 
#       is used to register the HA resource using srvctl. For example:
#         srvctl add database -d fsprdatl ...
#       Where: fsprdatl is the db_unique_name and is used for the 
#              Dictionary Key.
#       RegDbProvSchemeDD:
#       The provisioning scheme of the current configuration. For 
#       example db_unique_name, instance_name, node_name, state.
#---------------------------------------------------------------------------
def GetRegisteredDbAttributes(Crsctl_p_Stdout):

  # Each paragraph of the output from the crs_stat command
  # (separated by \n) represents a cluster resource. The
  # "Crsctl_p_Stdout = split(join(Crsctl_p_Stdout), '\n\n')" line below,
  # transforms Crsctl_p_Stdout into a list (array) where each cell,
  # Crsctl_p_Stdout[0]...[n], contains the configuraton of a cluster
  # resource.
  #
  # For example Crsctl_p_Stdout[0] would contain
  #  NAME=ora.hcmcfg.db
  #   TYPE=ora.database.type
  #   ENABLED@SERVERNAME(td01db02)=0
  #   GEN_START_OPTIONS@SERVERNAME(td01db01)=open
  #   GEN_START_OPTIONS@SERVERNAME(td01db02)=open
  #   GEN_USR_ORA_INST_NAME@SERVERNAME(td01db01)=hcmcfg1
  #   GEN_USR_ORA_INST_NAME@SERVERNAME(td01db02)=hcmcfg2
  #   RESTART_ATTEMPTS=2
  #   RESTART_COUNT=0
  #   USR_ORA_INST_NAME@SERVERNAME(td01db01)=hcmcfg1
  #   USR_ORA_INST_NAME@SERVERNAME(td01db02)=hcmcfg2
  #   FAILURE_THRESHOLD=1
  #   FAILURE_COUNT=0
  #   TARGET=ONLINE
  #   STATE=ONLINE on td01db01
  StanzaList     = split(Crsctl_p_Stdout, '\n\nNAME=')

  # Parse all stanzas for specific cluster resources.
  RegisteredDbDD = {}
  DatabaseList   = []
  for Stanza in StanzaList:
    # Need to put 'NAME=' back on the front of the record since it was removed in the split '\n\nNAME=' above. 
    # This is a safe thing to do since it was explicitely removed by the split(Crsctl_p_Stdout, '\n\nNAME=')
    # command above.
    Stanza = 'NAME=' + Stanza

    # Looking for a database stanza
    pos = Stanza.find('TYPE=ora.database.type')

    # Found a database stanza. Now parse it for attributes.
    if (pos >= 0):
      DictionaryKey                          = ''
      RegisteredSvcDict                      = {}
      Name                                   = ''
      Type                                   = ''
      Acl                                    = ''
      ActionFailureTemplate                  = ''
      ActionScript                           = ''
      ActivePlacement                        = ''
      AgentFilename                          = ''
      AutoStart                              = ''
      Cardinality                            = ''
      CheckInterval                          = ''
      CheckTimeout                           = ''
      ClusterDatabase                        = ''
      DatabaseType                           = ''
      DbUniqueName                           = ''
      DefaultTemplate                        = ''
      Degree                                 = ''
      Description                            = ''
      Enabled                                = ''
      EnabledServerNameList                  = []
      FailoverDelay                          = ''
      FailureInterval                        = ''
      FailureThreshold                       = ''
      GenAuditFileDest                       = ''
      GenStartOptions                        = ''
      GenStartOptionsServernameList          = []
      GenUsrOraInstNameServernameList        = []
      HostingMembers                         = ''
      InstanceFailover                       = ''
      Load                                   = ''
      LoggingLevel                           = ''
      ManagementPolicy                       = ''
      NlsLang                                = ''
      NotRestartingTemplate                  = ''
      OfflineCheckInterval                   = ''
      OnlineRelocationTimeout                = ''
      OracleHome                             = ''
      Placement                              = ''
      ProfileChangeTemplate                  = ''
      RestartAttempts                        = ''
      Role                                   = ''
      ScriptTimeout                          = ''
      ServerPools                            = ''
      Spfile                                 = ''
      StartDependencies                      = ''
      StartTimeout                           = ''
      StateChangeTemplate                    = ''
      StopDependencies                       = ''
      StopTimeout                            = ''
      TypeVersion                            = ''
      UptimeThreshold                        = ''
      UsrOraDbName                           = ''
      UsrOraDomain                           = ''
      UsrOraEnv                              = ''
      UsrOraFlags                            = ''
      UsrOraInstName                         = ''
      UsrOraInstName                         = ''
      UsrOraInstNameServernameList           = []
      UsrOraOpenMode                         = ''
      UsrOraOpi                              = ''
      UsrOraStopMode                         = ''
      Version                                = ''

      # Create a list of all the attributes of the resource
      ResourceAttributes = Stanza.split('\n')

      # Parse the attributes of a database resource
      for Attribute in ResourceAttributes:

        # NAME=ora.bitrg.db
        pos2 = Attribute.find('NAME=', 0, 5)
        if (pos2 >= 0):
          Name          = Attribute[5:]
          DictionaryKey = Attribute.split('.')[1]

        # TYPE=ora.database.type
        pos2 = Attribute.find('TYPE=', 0, 5)
        if (pos2 >= 0):
          Type  = Attribute[5:]

        # ACL=owner:oracle:rwx,pgrp:oinstall:rwx,other::r--
        pos2 = Attribute.find('ACL=', 0, 4)
        if (pos2 >= 0):
          Acl  = Attribute[4:]

        # ACTION_FAILURE_TEMPLATE=
        pos2 = Attribute.find('ACTION_FAILURE_TEMPLATE=', 0, 24)
        if (pos2 >= 0):
          ActionFailureTemplate  = Attribute[24:]

        # ACTION_SCRIPT=
        pos2 = Attribute.find('ACTION_SCRIPT=', 0, 14)
        if (pos2 >= 0):
          ActionScript = Attribute[14:]

        # ACTIVE_PLACEMENT=1
        pos2 = Attribute.find('ACTIVE_PLACEMENT=', 0, 17)
        if (pos2 >= 0):
          ActivePlacement = Attribute[17:]

        # AGENT_FILENAME=%CRS_HOME%/bin/oraagent%CRS_EXE_SUFFIX%
        pos2 = Attribute.find('AGENT_FILENAME=', 0, 15)
        if (pos2 >= 0):
          AgentFilename = Attribute[15:]

        # AUTO_START=restore
        pos2 = Attribute.find('AUTO_START=', 0, 11)
        if (pos2 >= 0):
          AutoStart = Attribute[11:]

        # CARDINALITY=2
        pos2 = Attribute.find('CARDINALITY=', 0, 13)
        if (pos2 >= 0):
          Cardinality  = Attribute[13:]

        # CHECK_INTERVAL=1
        pos2 = Attribute.find('CHECK_INTERVAL=', 0, 15)
        if (pos2 >= 0):
          CheckInterval  = Attribute[15:]

        # CHECK_TIMEOUT=30
        pos2 = Attribute.find('CHECK_TIMEOUT=', 0, 14)
        if (pos2 >= 0):
          CheckTimeout  = Attribute[14:]

        # CLUSTER_DATABASE=true
        pos2 = Attribute.find('CLUSTER_DATABASE=', 0, 17)
        if (pos2 >= 0):
          ClusterDatabase = Attribute[17:]

        # DATABASE_TYPE=RAC
        pos2 = Attribute.find('DATABASE_TYPE=', 0, 14)
        if (pos2 >= 0):
          DatabaseType = Attribute[14:]

        # DB_UNIQUE_NAME=bitrg
        pos2 = Attribute.find('DB_UNIQUE_NAME=', 0, 15)
        if (pos2 >= 0):
          DbUniqueName = Attribute[15:]

        # DEFAULT_TEMPLATE=PROPERTY(RESOURCE_CLASS=database) PROPERTY(DB_UNIQUE_NAME= CONCAT(PARSE(%NAME%, ., 2), ...
        # ... %USR_ORA_DOMAIN%, .)) ELEMENT(INSTANCE_NAME= %GEN_USR_ORA_INST_NAME%) ELEMENT(DATABASE_TYPE= %DATABASE_TYPE%)
        pos2 = Attribute.find('DEFAULT_TEMPLATE=', 0, 17)
        if (pos2 >= 0):
          pos2 = Attribute.find('=')
          DefaultTemplate = Attribute[17:]

        # DEGREE=1
        pos2 = Attribute.find('DEGREE=', 0, 7)
        if (pos2 >= 0):
          Degree = Attribute[7:]

        # DESCRIPTION=Oracle Database resource
        pos2 = Attribute.find('DESCRIPTION=', 0, 12)
        if (pos2 >= 0):
          Description = Attribute[12:]

        # ENABLED=1
        pos2 = Attribute.find('ENABLED=', 0, 8)
        if (pos2 >= 0):
          Enabled = Attribute[8:]

        # ----------------------------------------------------------------------------
        #  This attribute only appears to be visible if the 'srvctl enable/disable'
        #  has been run on the instances. Might need to run the enable/disable
        #  once just to seed the non-default value. Assuming at this point that
        #  the default value is 'enabled'.
        # ----------------------------------------------------------------------------
        #  > crsctl status resource  ora.dbfs.db -p  | egrep -i 'dbfs.db|ENABLED\@SERVERNAME'
        #  NAME=ora.dbfs.db
        #  ENABLED@SERVERNAME(enkdb03)=1
        #  ENABLED@SERVERNAME(enkdb04)=1
        # ----------------------------------------------------------------------------
        # ENABLED@SERVERNAME(td01db02)=0
        pos2 = Attribute.find('ENABLED@SERVERNAME', 0, 18)
        if (pos2 >= 0):
          (junk, keep)  = Attribute.split('(')             # junk is ENABLED@SERVERNAME, keep = td01db02)=0
          (hname, keep) = keep.split(')')                  # hname is td01db02,          keep is )=0
          (junk, opt)   = keep.split('=')                  # junk is  ,                  opt is 0
          EnabledServerNameList.append(hname + '=' + opt)
          del(junk, hname, opt)

        # FAILOVER_DELAY=0
        pos2 = Attribute.find('FAILOVER_DELAY=', 0, 15)
        if (pos2 >= 0):
          FailoverDelay = Attribute[15:]

        # FAILURE_INTERVAL=60
        pos2 = Attribute.find('FAILURE_INTERVAL=', 0, 17)
        if (pos2 >= 0):
          FailureInterval = Attribute[17:]

        # FAILURE_THRESHOLD=1
        pos2 = Attribute.find('FAILURE_THRESHOLD=', 0, 18)
        if (pos2 >= 0):
          FailureThreshold = Attribute[18:]

        # GEN_AUDIT_FILE_DEST=/u01/app/oracle/admin/bitrg/adump
        pos2 = Attribute.find('GEN_AUDIT_FILE_DEST=', 0, 20)
        if (pos2 >= 0):
          GenAuditFileDest = Attribute[20:]

        ###! # GEN_START_OPTIONS=
        # GEN_START_OPTIONS@SERVERNAME(td01db02)=open
        pos2 = Attribute.find('GEN_START_OPTIONS@SERVERNAME', 0, 28)
        if (pos2 >= 0):
          (junk, keep) = Attribute.split('(')          # junk is GEN_START_OPTIONS@SERVERNAME, keep = td01db02)=open
          (hname, keep) = keep.split(')')              # hname is td01db02,                    keep is =open
          (junk, state) = keep.split('=')              # junk is ,                             stat is 0
          GenStartOptionsServernameList.append(hname + '=' + state)
          del (junk, hname, state)

        # GEN_USR_ORA_INST_NAME@SERVERNAME(td01db02)=bitrg2
        pos2 = Attribute.find('GEN_USR_ORA_INST_NAME@SERVERNAME', 0, 32)
        if (pos2 >= 0):
          (junk, keep) = Attribute.split('(')           # junk is GEN_START_OPTIONS@SERVERNAME, keep = td01db02)=bitrg2
          (hname, keep) = keep.split(')')               # hname is td01db02,                    keep is =open
          (junk, iname) = keep.split('=')               # junk is ),                            stat is 0
          GenUsrOraInstNameServernameList.append(hname + '=' + iname)
          del (junk, hname, iname)

        # HOSTING_MEMBERS=
        pos2 = Attribute.find('HOSTING_MEMBERS=', 0, 16)
        if (pos2 >= 0):
          HostingMembers = Attribute[16:]

        # INSTANCE_FAILOVER=0
        pos2 = Attribute.find('INSTANCE_FAILOVER=', 0, 18)
        if (pos2 >= 0):
          InstanceFailover = Attribute[18:]

        # LOAD=1
        pos2 = Attribute.find('LOAD=', 0, 5)
        if (pos2 >= 0):
          Load = Attribute[5:]

        # LOGGING_LEVEL=1
        pos2 = Attribute.find('LOGGING_LEVEL=', 0, 14)
        if (pos2 >= 0):
          LoggingLevel = Attribute[14:]

        # MANAGEMENT_POLICY=AUTOMATIC
        pos2 = Attribute.find('MANAGEMENT_POLICY=', 0, 18)
        if (pos2 >= 0):
          ManagementPolicy = Attribute[18:]

        # NLS_LANG=
        pos2 = Attribute.find('NLS_LANG=', 0, 9)
        if (pos2 >= 0):
          NlsLang = Attribute[9:]

        # NOT_RESTARTING_TEMPLATE=
        pos2 = Attribute.find('NOT_RESTARTING_TEMPLATE=', 0, 24)
        if (pos2 >= 0):
          NotRestartingTemplate = Attribute[24:]

        # OFFLINE_CHECK_INTERVAL=0
        pos2 = Attribute.find('OFFLINE_CHECK_INTERVAL=', 0, 23)
        if (pos2 >= 0):
          OfflineCheckInterval = Attribute[23:]

        # ONLINE_RELOCATION_TIMEOUT=0
        pos2 = Attribute.find('ONLINE_RELOCATION_TIMEOUT=', 0, 26)
        if (pos2 >= 0):
          OnlineRelocationTimeout = Attribute[26:]

        # ORACLE_HOME=/u01/app/oracle/product/11.2.0/dbhome_1
        pos2 = Attribute.find('ORACLE_HOME=', 0, 12)
        if (pos2 >= 0):
          OracleHome = Attribute[12:]

        # PLACEMENT=restricted
        pos2 = Attribute.find('PLACEMENT=', 0, 10)
        if (pos2 >= 0):
          Placement = Attribute[10:]

        # PROFILE_CHANGE_TEMPLATE=
        pos2 = Attribute.find('PROFILE_CHANGE_TEMPLATE=', 0, 24)
        if (pos2 >= 0):
          ProfileChangeTemplate = Attribute[24:]

        # RESTART_ATTEMPTS=2
        pos2 = Attribute.find('RESTART_ATTEMPTS=', 0, 17)
        if (pos2 >= 0):
          RestartAttempts = Attribute[17:]

        # ROLE=PRIMARY
        pos2 = Attribute.find('ROLE=', 0, 5)
        if (pos2 >= 0):
          Role = Attribute[5:]

        # SCRIPT_TIMEOUT=60
        pos2 = Attribute.find('SCRIPT_TIMEOUT=', 0, 15)
        if (pos2 >= 0):
          ScriptTimeout = Attribute[15:]

        # SERVER_POOLS=ora.bitrg
        pos2 = Attribute.find('SERVER_POOLS=', 0, 13)
        if (pos2 >= 0):
          ServerPools = Attribute[13:]

        # SPFILE=+DATA/BITRG/spfilebitrg.ora
        pos2 = Attribute.find('SPFILE=', 0, 7)
        if (pos2 >= 0):
          Spfile = Attribute[7:]

        # START_DEPENDENCIES=hard(ora.DATA.dg,ora.RECO.dg) weak(type:ora.listener.type,global: ...
        # ... type:ora.scan_listener.type,uniform:ora.ons,global:ora.gns) pullup(ora.DATA.dg,ora.RECO.dg)
        pos2 = Attribute.find('START_DEPENDENCIES=', 0, 19)
        if (pos2 >= 0):
          StartDependencies = Attribute[19:]

        # START_TIMEOUT=600
        pos2 = Attribute.find('START_TIMEOUT=', 0, 14)
        if (pos2 >= 0):
          StartTimeout = Attribute[14:]

        # STATE_CHANGE_TEMPLATE=
        pos2 = Attribute.find('STATE_CHANGE_TEMPLATE=', 0, 22)
        if (pos2 >= 0):
          StateChangeTemplate = Attribute[22:]

        # STOP_DEPENDENCIES=hard(intermediate:ora.asm,shutdown:ora.DATA.dg,shutdown:ora.RECO.dg)
        pos2 = Attribute.find('STOP_DEPENDENCIES=', 0, 18)
        if (pos2 >= 0):
          StopDependencies = Attribute[18:]

        # STOP_TIMEOUT=600
        pos2 = Attribute.find('STOP_TIMEOUT=', 0, 13)
        if (pos2 >= 0):
          StopTimeout = Attribute[13:]

        # TYPE_VERSION=2.2
        pos2 = Attribute.find('TYPE_VERSION=', 0, 13)
        if (pos2 >= 0):
          TypeVersion = Attribute[13:]

        # UPTIME_THRESHOLD=1h
        pos2 = Attribute.find('UPTIME_THRESHOLD=', 0, 17)
        if (pos2 >= 0):
          UptimeThreshold = Attribute[17:]

        # USR_ORA_DB_NAME=bitrg
        pos2 = Attribute.find('USR_ORA_DB_NAME=', 0, 16)
        if (pos2 >= 0):
          UsrOraDbName = Attribute[16:]

        # USR_ORA_DOMAIN=tnd.us.cbre.net
        pos2 = Attribute.find('USR_ORA_DOMAIN=', 0, 15)
        if (pos2 >= 0):
          UsrOraDomain = Attribute[15:]

        # USR_ORA_ENV=
        pos2 = Attribute.find('USR_ORA_ENV=', 0, 12)
        if (pos2 >= 0):
          UsrOraEnv = Attribute[12:]

        # USR_ORA_FLAGS=
        pos2 = Attribute.find('USR_ORA_FLAGS=', 0, 14)
        if (pos2 >= 0):
          UsrOraFlags = Attribute[14:]

        # USR_ORA_INST_NAME=
        pos2 = Attribute.find('USR_ORA_INST_NAME=', 0, 18)
        if (pos2 >= 0):
          UsrOraInstName = Attribute[18:]

        # USR_ORA_INST_NAME@SERVERNAME(td01db02)=bitrg2
        pos2 = Attribute.find('USR_ORA_INST_NAME@SERVERNAME', 0, 28)
        if (pos2 >= 0):
          (junk, keep) = Attribute.split('(')           # junk is USR_ORA_INST_NAME@SERVERNAME, keep = td01db02)=bitrg2
          (hname, keep) = keep.split(')')               # hname is td01db02,                    keep is =open
          (junk, state) = keep.split('=')               # junk is ),                            stat is 0
          UsrOraInstNameServernameList.append(hname + '=' + state)
          del (junk, hname, state)

        # USR_ORA_OPEN_MODE=open
        pos2 = Attribute.find('USR_ORA_OPEN_MODE=', 0, 18)
        if (pos2 >= 0):
          UsrOraOpenMode = Attribute[18:]

        # USR_ORA_OPI=false
        pos2 = Attribute.find('USR_ORA_OPI=', 0, 12)
        if (pos2 >= 0):
          UsrOraOpi = Attribute[12:]

        # USR_ORA_STOP_MODE=immediate
        pos2 = Attribute.find('USR_ORA_STOP_MODE=', 0, 18)
        if (pos2 >= 0):
          UsrOraStopMode = Attribute[18:]

        # VERSION=11.2.0.2.0
        pos2 = Attribute.find('VERSION=', 0, 8)
        if (pos2 >= 0):
          Version = Attribute[8:]

      # Done parsing. Assign this database's attributes to a dictionary object.
      RegisteredDbDict = {
       'Name'                            : Name,
       'Type'                            : Type,
       'Acl'                             : Acl,
       'ActionFailureTemplate'           : ActionFailureTemplate,
       'ActionScript'                    : ActionScript,
       'ActivePlacement'                 : ActivePlacement,
       'AgentFilename'                   : AgentFilename,
       'AutoStart'                       : AutoStart,
       'Cardinality'                     : Cardinality,
       'CheckInterval'                   : CheckInterval,
       'CheckTimeout'                    : CheckTimeout,
       'ClusterDatabase'                 : ClusterDatabase,
       'DatabaseType'                    : DatabaseType,
       'DbUniqueName'                    : DbUniqueName,
       'DefaultTemplate'                 : DefaultTemplate,
       'Degree'                          : Degree,
       'Description'                     : Description,
       'Enabled'                         : Enabled,
       'EnabledServerNameList'           : EnabledServerNameList,
       'FailoverDelay'                   : FailoverDelay,
       'FailureInterval'                 : FailureInterval,
       'FailureThreshold'                : FailureThreshold,
       'GenAuditFileDest'                : GenAuditFileDest,
       'GenStartOptions'                 : GenStartOptions,
       'GenStartOptionsServernameList'   : GenStartOptionsServernameList,
       'GenUsrOraInstNameServernameList' : GenUsrOraInstNameServernameList,
       'HostingMembers'                  : HostingMembers,
       'InstanceFailover'                : InstanceFailover,
       'Load'                            : Load,
       'LoggingLevel'                    : LoggingLevel,
       'ManagementPolicy'                : ManagementPolicy,
       'NlsLang'                         : NlsLang,
       'NotRestartingTemplate'           : NotRestartingTemplate,
       'OfflineCheckInterval'            : OfflineCheckInterval,
       'OnlineRelocationTimeout'         : OnlineRelocationTimeout,
       'OracleHome'                      : OracleHome,
       'Placement'                       : Placement,
       'ProfileChangeTemplate'           : ProfileChangeTemplate,
       'RestartAttempts'                 : RestartAttempts,
       'Role'                            : Role,
       'ScriptTimeout'                   : ScriptTimeout,
       'ServerPools'                     : ServerPools,
       'Spfile'                          : Spfile,
       'StartDependencies'               : StartDependencies,
       'StartTimeout'                    : StartTimeout,
       'StateChangeTemplate'             : StateChangeTemplate,
       'StopDependencies'                : StopDependencies,
       'StopTimeout'                     : StopTimeout,
       'TypeVersion'                     : TypeVersion,
       'UptimeThreshold'                 : UptimeThreshold,
       'UsrOraDbName'                    : UsrOraDbName,
       'UsrOraDomain'                    : UsrOraDomain,
       'UsrOraEnv'                       : UsrOraEnv,
       'UsrOraFlags'                     : UsrOraFlags,
       'UsrOraInstName'                  : UsrOraInstName,
       'UsrOraInstNameServernameList'    : UsrOraInstNameServernameList,
       'UsrOraOpenMode'                  : UsrOraOpenMode,
       'UsrOraOpi'                       : UsrOraOpi,
       'UsrOraStopMode'                  : UsrOraStopMode,
       'Version'                         : Version,
      }
      RegisteredDbDD[Name] = RegisteredDbDict

  # Create a provisioned structure
  RegDbProvSchemeDD = {}
  for DbKey in sorted(RegisteredDbDD.keys()):
    DbUniqueName = RegisteredDbDD[DbKey]['DbUniqueName']

    # We'll be using data from these Attributes...
    # -----------------------------------------------------------------------
    # RegisteredDbDD[DbKey]['EnabledServerNameList']   # <--- if this key is missing, the default is 'enabled'
    #   ENABLED@SERVERNAME(enkdb03)=1
    #   ENABLED@SERVERNAME(enkdb04)=1
    # RegisteredDbDD[DbKey]['GenStartOptionsServernameList']
    #   GEN_START_OPTIONS@SERVERNAME(enkdb03)=open
    #   GEN_START_OPTIONS@SERVERNAME(enkdb04)=open
    # RegisteredDbDD[DbKey]['GenUsrOraInstNameServernameList']
    #   GEN_USR_ORA_INST_NAME@SERVERNAME(enkdb03)=DBFS1
    #   GEN_USR_ORA_INST_NAME@SERVERNAME(enkdb04)=DBFS2
    # -----------------------------------------------------------------------
    NodeState = ''
    ProvNode  = ''
    RegDbProvSchemeDD[DbUniqueName] = {
      'node1' : '',
      'node2' : '',
      'node3' : '',
      'node4' : '',
      'node5' : '',
      'node6' : '',
      'node7' : '',
      'node8' : '',
    }

    ###! for nodeinst in RegisteredDbDD[DbKey]['UsrOraInstNameServernameList']:               # incomplete node list. switching to GenUsrOra...
    for nodeinst in RegisteredDbDD[DbKey]['GenUsrOraInstNameServernameList']:
      (NodeName, InstName) = nodeinst.split('=')
      NodeId = GetNodeId(NodeName)
      NodeState = 'enabled'    # The default
      if (RegisteredDbDD[DbKey]['EnabledServerNameList']) != []:
        for nodestate in RegisteredDbDD[DbKey]['EnabledServerNameList']:
          nodename, nodestate = nodestate.split('=')
          if NodeName == nodename:
            if nodestate == '0':
              NodeState = 'disabled'
      RegDbProvSchemeDD[DbUniqueName]['node' + NodeId] = DbUniqueName + ',' + InstName + ',' + NodeName + ',' + NodeState
  return(RegisteredDbDD, RegDbProvSchemeDD)
# End GetRegisteredDbAttributes()


# Def : GetRegisteredSvcAttributes()
# Desc: Processes the output from the GetCrsctlStatPOutput function,
#       filters out the cluster service name resources and their attributes.
# Args: Crsctl_p_Stdout
# Retn: RegisteredSvcDD:
#       Dictionary of dictionaries structure containing registered databases
#       and their cluster attributes. This allows easy lookup by database
#       name later on in the program. The db_unique_name is the value that 
#       is used to register the HA resource using srvctl. For example:
#         srvctl add database -d fsprdatl ...
#       Where: fsprdatl is the db_unique_name and is used for the 
#              Dictionary Key.
#       RegSvcProvSchemeDD:
#       The provisioning scheme of the current configuration. For example:
#       db_unique_name, instance_name, service_name, node_name, state.
#---------------------------------------------------------------------------
def GetRegisteredSvcAttributes(Crsctl_p_Stdout, RegisteredDbDD):
  # Each paragraph of the output from the crs_stat command
  # (separated by \n) represents a cluster resource. The
  # "Crsctl_p_Stdout = split(join(Crsctl_p_Stdout), '\n\n')" line below,
  # transforms Crsctl_p_Stdout into a list (array) where each cell,
  # Crsctl_p_Stdout[0]...[n], contains the configuraton of a cluster
  # resource.
  #
  # For example Crsctl_p_Stdout[0] would contain
  #  NAME=ora.hcmcfg.db
  #   TYPE=ora.service.type
  #   ENABLED@SERVERNAME(td01db02)=0
  #   GEN_START_OPTIONS@SERVERNAME(td01db01)=open
  #   GEN_START_OPTIONS@SERVERNAME(td01db02)=open
  #   GEN_USR_ORA_INST_NAME@SERVERNAME(td01db01)=hcmcfg1
  #   GEN_USR_ORA_INST_NAME@SERVERNAME(td01db02)=hcmcfg2
  #   RESTART_ATTEMPTS=2
  #   RESTART_COUNT=0
  #   USR_ORA_INST_NAME@SERVERNAME(td01db01)=hcmcfg1
  #   USR_ORA_INST_NAME@SERVERNAME(td01db02)=hcmcfg2
  #   FAILURE_THRESHOLD=1
  #   FAILURE_COUNT=0
  #   TARGET=ONLINE
  #   STATE=ONLINE on td01db01
  StanzaList      = split(Crsctl_p_Stdout, '\n\nNAME=')
  RegisteredSvcDD = {}

  for Stanza in StanzaList:
    # Parse all stanzas for specific cluster resources.

    # Need to put 'NAME=' back on the front of the record since it
    # was removed in the split '\n\nNAME=' above. This should be a
    # safe thing to do since it was removed in the split.
    Stanza = 'NAME=' + Stanza

    # Looking for a database stanza
    pos = Stanza.find('TYPE=ora.service.type')

    # Found a service name stanza. Now parse it for attributes.
    if (pos >= 0):
      RegisteredSvcDict     = {}
      Name                  = ''
      DbUniqueName          = ''
      Type                  = ''
      Acl                   = ''
      ActionFailureTemplate = ''
      ActionScript          = ''
      ActivePlacement       = ''
      Agentfilename         = ''
      AgentParameters       = ''
      AqHaNotification      = ''
      AutoStart             = ''
      Cardinality           = ''
      CheckInterval         = ''
      CheckTimeout          = ''
      ClbGoal               = ''
      DefaultTemplate       = ''
      Degree                = ''
      Description           = ''
      Dtp                   = ''
      Edition               = ''
      Enabled               = ''
      EnabledServernameList = []
      FailoverDelay         = ''
      FailoverMethod        = ''
      FailoverRetries       = ''
      FailoverType          = ''
      FailureInterval       = ''
      FailureThreshold      = ''
      GenServiceName        = ''
      HostingMembers        = ''
      Load                  = ''
      LoggingLevel          = ''
      ManagementPolicy      = ''
      Nlslang               = ''
      NotRestartingTemplate = ''
      OfflineCheckInterval  = ''
      Placement             = ''
      ProfileChangeTemplate = ''
      RestartAttempts       = ''
      RlbGoal               = ''
      Role                  = ''
      ScriptTimeout         = ''
      ServerPools           = ''
      ServiceName           = ''
      StartDependencies     = ''
      StartTimeout          = ''
      StateChangeTemplate   = ''
      StopDependencies      = ''
      StopTimeout           = ''
      TafPolicy             = ''
      TypeVersion           = ''
      UptimeThreshold       = ''
      UsrOraDisconnect      = ''
      UsrOraEnv             = ''
      UsrOraFlags           = ''
      UsrOraOpenMode        = ''
      UsrOraOpi             = ''
      UsrOraStopMode        = ''
      Version               = ''

      # Create a list of all the attributes of the resource
      ResourceAttributes = Stanza.split('\n')

      # Parse the attributes of a database resource
      for Attribute in ResourceAttributes:

        # NAME=ora.bidev01.bidev01ah.svc
        pos2 = Attribute.find('NAME=', 0, 5)
        if (pos2 >= 0):
          Name = Attribute[5:]

        # TYPE=ora.service.type
        pos2 = Attribute.find('TYPE=', 0, 5)
        if (pos2 >= 0):
          Type = Attribute[5:]

        # ACL=owner:oracle:rwx,pgrp:oinstall:rwx,other::r--
        pos2 = Attribute.find('ACL=', 0, 5)
        if (pos2 >= 0):
          Acl = Attribute[5:]

        # ACTION_FAILURE_TEMPLATE=
        pos2 = Attribute.find('ACTION_FAILURE_TEMPLATE=', 0, 24)
        if (pos2 >= 0):
          ActionFailureTemplate = Attribute[24:]

        # ACTION_SCRIPT=
        pos2 = Attribute.find('ACTION_SCRIPT=', 0, 14)
        if (pos2 >= 0):
          ActionScript = Attribute[14:]

        # ACTIVE_PLACEMENT=1
        pos2 = Attribute.find('ACTIVE_PLACEMENT=', 0, 17)
        if (pos2 >= 0):
          ActivePlacement = Attribute[17:]

        # AGENT_FILENAME=%CRS_HOME%/bin/oraagent%CRS_EXE_SUFFIX%
        pos2 = Attribute.find('AGENT_FILENAME=', 0, 15)
        if (pos2 >= 0):
          ActionScript = Attribute[15:]

        # AGENT_PARAMETERS=
        pos2 = Attribute.find('AGENT_PARAMETERS=', 0, 17)
        if (pos2 >= 0):
          ActionScript = Attribute[17:]

        # AQ_HA_NOTIFICATION=0
        pos2 = Attribute.find('AQ_HA_NOTIFICATION=', 0, 19)
        if (pos2 >= 0):
          AqHaNotification = Attribute[19:]

        # AUTO_START=restore
        pos2 = Attribute.find('AUTO_START=', 0, 11)
        if (pos2 >= 0):
          AutoStart = Attribute[11:]

        # CARDINALITY=2
        pos2 = Attribute.find('CARDINALITY=', 0, 12)
        if (pos2 >= 0):
          Cardinality = Attribute[12:]

        # CHECK_INTERVAL=600
        pos2 = Attribute.find('CHECK_INTERVAL=', 0, 15)
        if (pos2 >= 0):
          CheckInterval = Attribute[15:]

        # CHECK_TIMEOUT=30
        pos2 = Attribute.find('CHECK_TIMEOUT=', 0, 14)
        if (pos2 >= 0):
          CheckTimeout = Attribute[14:]

        # CLB_GOAL=LONG
        pos2 = Attribute.find('CLB_GOAL=', 0, 9)
        if (pos2 >= 0):
          ClbGoal = Attribute[9:]

        # DEFAULT_TEMPLATE=PROPERTY(RESOURCE_CLASS=service) PROPERTY(SERVICE_NAME=%GEN_SERVICE_NAME%) ...
        # ... PROPERTY(DB_UNIQUE_NAME=CONCAT(PARSE(%NAME%, ., 2), STAT(ora.bidev01.db, USR_ORA_DOMAIN), .)) ...
        # ... ELEMENT(INSTANCE_NAME=STAT(ora.bidev01.db, GEN_USR_ORA_INST_NAME))
        pos2 = Attribute.find('DEFAULT_TEMPLATE=', 0, 17)
        if (pos2 >= 0):
          DefaultTemplate = Attribute[17:]

        # DEGREE=1
        pos2 = Attribute.find('DEGREE=', 0, 7)
        if (pos2 >= 0):
          Degree = Attribute[7:]

        # DESCRIPTION=Oracle Service resource
        pos2 = Attribute.find('DESCRIPTION=', 0, 12)
        if (pos2 >= 0):
          Description = Attribute[12:]

        # DTP=0
        pos2 = Attribute.find('DTP=', 0, 4)
        if (pos2 >= 0):
          Dtp = Attribute[4:]

        # EDITION=
        pos2 = Attribute.find('EDITION=', 0, 8)
        if (pos2 >= 0):
          Edition = Attribute[8:]

        # ENABLED=1
        pos2 = Attribute.find('ENABLED=', 0, 8)
        if (pos2 >= 0):
          Enabled = Attribute[8:]

        # ENABLED@SERVERNAME(td01db04)=0
        pos2 = Attribute.find('ENABLED@SERVERNAME', 0, 18)
        if (pos2 >= 0):
          junk, keep = Attribute.split('(')
          esn, keep  = keep.split(')')
          ess        = keep.split('=')[1]
          EnabledServernameList.append(esn + ':' + ess)
          del(junk, keep, esn, ess)

        # FAILOVER_DELAY=0
        pos2 = Attribute.find('FAILOVER_DELAY=', 0, 15)
        if (pos2 >= 0):
          FailoverDelay = Attribute[15:]

        # FAILOVER_METHOD=NONE
        pos2 = Attribute.find('FAILOVER_METHOD=', 0, 16)
        if (pos2 >= 0):
          FailoverMethod = Attribute[16:]

        # FAILOVER_RETRIES=0
        pos2 = Attribute.find('FAILOVER_RETRIES=', 0, 17)
        if (pos2 >= 0):
          FailoverRetries = Attribute[17:]

        # FAILOVER_TYPE=
        pos2 = Attribute.find('FAILOVER_TYPE=', 0, 14)
        if (pos2 >= 0):
          FailoverType = Attribute[14:]

        # FAILURE_INTERVAL=0
        pos2 = Attribute.find('FAILURE_INTERVAL=', 0, 17)
        if (pos2 >= 0):
          FailureInterval = Attribute[17:]

        # FAILURE_THRESHOLD=0
        pos2 = Attribute.find('FAILURE_THRESHOLD=', 0, 18)
        if (pos2 >= 0):
          FailureThreshold = Attribute[18:]

        # GEN_SERVICE_NAME=bidev01AH.tnd.us.cbre.net
        pos2 = Attribute.find('GEN_SERVICE_NAME=', 0, 17)
        if (pos2 >= 0):
          GenServiceName = Attribute[17:]

        # HOSTING_MEMBERS=
        pos2 = Attribute.find('HOSTING_MEMBERS=', 0, 16)
        if (pos2 >= 0):
          HostingMembers = Attribute[16:]

        # LOAD=1
        pos2 = Attribute.find('LOAD=', 0, 5)
        if (pos2 >= 0):
          Load = Attribute[5:]

        # LOGGING_LEVEL=1
        pos2 = Attribute.find('LOGGING_LEVEL=', 0, 14)
        if (pos2 >= 0):
          LoggingLevel = Attribute[14:]

        # MANAGEMENT_POLICY=AUTOMATIC
        pos2 = Attribute.find('MANAGEMENT_POLICY=', 0, 18)
        if (pos2 >= 0):
          ManagementPolicy = Attribute[18:]

        # NLS_LANG=
        pos2 = Attribute.find('NLS_LANG=', 0, 9)
        if (pos2 >= 0):
          NlsLang = Attribute[9:]

        # NOT_RESTARTING_TEMPLATE=
        pos2 = Attribute.find('NOT_RESTARTING_TEMPLATE=', 0, 24)
        if (pos2 >= 0):
          NotRestartingTemplate = Attribute[24:]

        # OFFLINE_CHECK_INTERVAL=0
        pos2 = Attribute.find('OFFLINE_CHECK_INTERVAL=', 0, 23)
        if (pos2 >= 0):
          OfflineCheckInterval = Attribute[23:]

        # PLACEMENT=restricted
        pos2 = Attribute.find('PLACEMENT=', 0, 10)
        if (pos2 >= 0):
          Placement = Attribute[10:]

        # PROFILE_CHANGE_TEMPLATE=
        pos2 = Attribute.find('PROFILE_CHANGE_TEMPLATE=', 0, 24)
        if (pos2 >= 0):
          ProfileChangeTemplate = Attribute[24:]

        # RESTART_ATTEMPTS=0
        pos2 = Attribute.find('RESTART_ATTEMPTS=', 0, 17)
        if (pos2 >= 0):
          RestartAttempts = Attribute[17:]

        # RLB_GOAL=NONE
        pos2 = Attribute.find('RLB_GOAL=', 0, 9)
        if (pos2 >= 0):
          RlbGoal = Attribute[9:]

        # ROLE=PRIMARY
        pos2 = Attribute.find('ROLE=', 0, 5)
        if (pos2 >= 0):
          Role = Attribute[5:]

        # SCRIPT_TIMEOUT=60
        pos2 = Attribute.find('SCRIPT_TIMEOUT=', 0, 15)
        if (pos2 >= 0):
          ScriptTimeout = Attribute[15:]

        # SERVER_POOLS=ora.bidev01_bidev01AH
        pos2 = Attribute.find('SERVER_POOLS=', 0, 13)
        if (pos2 >= 0):
          ServerPools = Attribute[13:]

        # SERVICE_NAME=bidev01AH
        pos2 = Attribute.find('SERVICE_NAME=', 0, 13)
        if (pos2 >= 0):
          ServiceName = Attribute[13:]

        # START_DEPENDENCIES=hard(ora.bidev01.db,type:ora.cluster_vip_net1.type) weak(type:ora.listener.type) ...
        # ... pullup(type:ora.cluster_vip_net1.type) pullup:always(ora.bidev01.db)
        pos2 = Attribute.find('START_DEPENDENCIES=', 0, 19)
        if (pos2 >= 0):
          StartDependencies = Attribute[19:]

        # START_TIMEOUT=600
        pos2 = Attribute.find('START_TIMEOUT=', 0, 14)
        if (pos2 >= 0):
          StartTimeout = Attribute[14:]

        # STATE_CHANGE_TEMPLATE=
        pos2 = Attribute.find('STATE_CHANGE_TEMPLATE=', 0, 5)
        if (pos2 >= 0):
          StateChangeTemplate = Attribute[5:]

        # STOP_DEPENDENCIES=hard(intermediate:ora.bidev01.db,intermediate:type:ora.cluster_vip_net1.type)
        pos2 = Attribute.find('STOP_DEPENDENCIES=', 0, 18)
        if (pos2 >= 0):
          StopDependencies = Attribute[18:]

        # STOP_TIMEOUT=600
        pos2 = Attribute.find('STOP_TIMEOUT=', 0, 13)
        if (pos2 >= 0):
          StopTimeout = Attribute[13:]

        # TAF_POLICY=BASIC
        pos2 = Attribute.find('TAF_POLICY=', 0, 11)
        if (pos2 >= 0):
          TafPolicy = Attribute[11:]

        # TYPE_VERSION=2.2
        pos2 = Attribute.find('TYPE_VERSION=', 0, 13)
        if (pos2 >= 0):
          TypeVersion = Attribute[13:]

        # UPTIME_THRESHOLD=1h
        pos2 = Attribute.find('UPTIME_THRESHOLD=', 0, 17)
        if (pos2 >= 0):
          UptimeThreshold = Attribute[17:]

        # USR_ORA_DISCONNECT=false
        pos2 = Attribute.find('USR_ORA_DISCONNECT=', 0, 19)
        if (pos2 >= 0):
          UsrOraDisconnect = Attribute[19:]

        # USR_ORA_ENV=
        pos2 = Attribute.find('USR_ORA_ENV=', 0, 12)
        if (pos2 >= 0):
          UsrOraEnv = Attribute[12:]

        # USR_ORA_FLAGS=
        pos2 = Attribute.find('USR_ORA_FLAGS=', 0, 14)
        if (pos2 >= 0):
          UsrOraFlags = Attribute[14:]

        # USR_ORA_OPEN_MODE=
        pos2 = Attribute.find('USR_ORA_OPEN_MODE=', 0, 18)
        if (pos2 >= 0):
          UsrOraOpenMode = Attribute[18:]

        # USR_ORA_OPI=false
        pos2 = Attribute.find('USR_ORA_OPI=', 0, 12)
        if (pos2 >= 0):
          UsrOraOpi = Attribute[12:]

        # USR_ORA_STOP_MODE=
        pos2 = Attribute.find('USR_ORA_STOP_MODE=', 0, 18)
        if (pos2 >= 0):
          UsrOraStopMode = Attribute[18:]

        # VERSION=11.2.0.2.0
        pos2 = Attribute.find('VERSION=', 0, 8)
        if (pos2 >= 0):
          Version = Attribute[8:]

      # Since the DB Unique Name isn't carried in the service name definitions we
      # need to parse DefaultTemplate for the registered name for the database
      # (ex. ora.demo.db) then use that to lookup the DbUniqueName in the
      # RegisteredDbDD structure we built earlier.
      #
      # DEFAULT_TEMPLATE=PROPERTY(RESOURCE_CLASS=service) PROPERTY(SERVICE_NAME=%GEN_SERVICE_NAME%) \
      #  PROPERTY(DB_UNIQUE_NAME=CONCAT(PARSE(%NAME%, ., 2), STAT(ora.labrat.db, USR_ORA_DOMAIN), .)) \
      #  ELEMENT(INSTANCE_NAME=STAT(ora.labrat.db, GEN_USR_ORA_INST_NAME))
      #
      # This is the part of the DefaultTemplate we are after... All we need is 'ora.labrat.db'.
      # PROPERTY(DB_UNIQUE_NAME=CONCAT(PARSE(%NAME%, ., 2), STAT(ora.labrat.db, USR_ORA_DOMAIN), .))
      #  ELEMENT(INSTANCE_NAME=STAT(ora.labrat.db, GEN_USR_ORA_INST_NAME))
      pos3 = DefaultTemplate.find('PROPERTY(DB_UNIQUE_NAME=')
      if (pos3 >= 0):
        Template = DefaultTemplate[pos3+9:]
        pos4 = Template.find('STAT(')
        Template = Template[pos4+5:]
        pos5 = Template.find(',')
        RegDbName = Template[:pos5]

      # And finally, Pass the registered name for this database to the GetRegDbAttr function to
      # get the DbUniqueName.
      DbUniqueName = GetRegDbAttr(RegisteredDbDD, RegDbName, 'DbUniqueName')

      # Done parsing. Assign this database's attributes to a dictionary object.
      RegisteredSvcDict = {
       'Name'                       : Name,
       'DbUniqueName'               : DbUniqueName,
       'Type'                       : Type,
       'Acl'                        : Acl,
       'ActionFailureTemplate'      : ActionFailureTemplate,
       'ActionScript'               : ActionScript,
       'ActivePlacement'            : ActivePlacement,
       'Agentfilename'              : Agentfilename,
       'AgentParameters'            : AgentParameters,
       'AqHaNotification'           : AqHaNotification,
       'AutoStart'                  : AutoStart,
       'Cardinality'                : Cardinality,
       'CheckInterval'              : CheckInterval,
       'CheckTimeout'               : CheckTimeout,
       'ClbGoal'                    : ClbGoal,
       'DefaultTemplate'            : DefaultTemplate,
       'Degree'                     : Degree,
       'Description'                : Description,
       'Dtp'                        : Dtp,
       'Edition'                    : Edition,
       'Enabled'                    : Enabled,
       'EnabledServernameList'      : EnabledServernameList,
       'FailoverDelay'              : FailoverDelay,
       'FailoverMethod'             : FailoverMethod,
       'FailoverRetries'            : FailoverRetries,
       'FailoverType'               : FailoverType,
       'FailureInterval'            : FailureInterval,
       'FailureThreshold'           : FailureThreshold,
       'GenServiceName'             : GenServiceName,
       'HostingMembers'             : HostingMembers,
       'Load'                       : Load,
       'LoggingLevel'               : LoggingLevel,
       'ManagementPolicy'           : ManagementPolicy,
       'Nlslang'                    : Nlslang,
       'NotRestartingTemplate'      : NotRestartingTemplate,
       'OfflineCheckInterval'       : OfflineCheckInterval,
       'Placement'                  : Placement,
       'ProfileChangeTemplate'      : ProfileChangeTemplate,
       'RestartAttempts'            : RestartAttempts,
       'RlbGoal'                    : RlbGoal,
       'Role'                       : Role,
       'ScriptTimeout'              : ScriptTimeout,
       'ServerPools'                : ServerPools,
       'ServiceName'                : ServiceName,
       'StartDependencies'          : StartDependencies,
       'StartTimeout'               : StartTimeout,
       'StateChangeTemplate'        : StateChangeTemplate,
       'StopDependencies'           : StopDependencies,
       'StopTimeout'                : StopTimeout,
       'TafPolicy'                  : TafPolicy,
       'TypeVersion'                : TypeVersion,
       'UptimeThreshold'            : UptimeThreshold,
       'UsrOraDisconnect'           : UsrOraDisconnect,
       'UsrOraEnv'                  : UsrOraEnv,
       'UsrOraFlags'                : UsrOraFlags,
       'UsrOraOpenMode'             : UsrOraOpenMode,
       'UsrOraOpi'                  : UsrOraOpi,
       'UsrOraStopMode'             : UsrOraStopMode,
       'Version'                    : Version
      }
      RegisteredSvcDD[Name] = RegisteredSvcDict

  # Create a provisioned structure
  RegSvcProvSchemeDD   = {}
  for SvcKey in sorted(RegisteredSvcDD.keys()):
    DbUniqueName          = RegisteredSvcDD[SvcKey]['DbUniqueName']
    ServiceName           = RegisteredSvcDD[SvcKey]['ServiceName']
    DefaultState          = RegisteredSvcDD[SvcKey]['Enabled']
    EnabledServernameList = RegisteredSvcDD[SvcKey]['EnabledServernameList']

    NodeState = ''
    ProvNode  = ''
    RegSvcProvSchemeDD[DbUniqueName + '~' + ServiceName] = {
      'node1' : '',
      'node2' : '',
      'node3' : '',
      'node4' : '',
      'node5' : '',
      'node6' : '',
      'node7' : '',
      'node8' : '',
    }

    ServerPool = RegisteredSvcDD[SvcKey]['ServerPools']
    ServerPoolList = RegisteredServerPoolDict[ServerPool]

    # Determine the state of the service for each node on which it has been defined.
    for NodeName in ServerPoolList:
      # Get the Database Instance Name for this node.
      GenUsrOraInstNameServernameList = GetRegDbAttr(RegisteredDbDD, 'ora.' + DbUniqueName + '.db', 'GenUsrOraInstNameServernameList')
      InstName = GetInstanceName(NodeName, GenUsrOraInstNameServernameList)

      ###! RegSvcProvSchemeDD['pauat~PAUATAH']
      ###~   'node1': '' ,
      ###~   'node2': 'pauat,pauat1,PAUATAH,td01db02,enabled'
      ###~   'node3': 'pauat,pauat2,PAUATAH,td01db03,enabled'
      ###~   'node4': '',
      ###~   'node5': '',
      ###~   'node6': '',
      ###~   'node7': '',
      ###~   'node8': ''
      ###~ }

      NodeId = GetNodeId(NodeName)
      if (DefaultState == '1'):
        NodeMask = NodeName + ':0'
        try:
          idx = EnabledServernameList.index(NodeMask)
          NodeState = 'disabled'
        except:
          idx = -1
          NodeState = 'enabled'
      else:
        if (DefaultState == '0'):
          NodeMask = NodeName + ':1'
          try:
            idx = EnabledServernameList.index(NodeMask)
            NodeState = 'enabled'
          except:
            idx = -1
            NodeState = 'disabled'
      RegSvcProvSchemeDD[DbUniqueName + '~' + ServiceName]['node' + NodeId] = DbUniqueName + ',' + InstName + ',' + ServiceName + ',' + NodeName + ',' + NodeState
  return(RegisteredSvcDD, RegSvcProvSchemeDD)
# End GetRegisteredSvcAttributes()


# Def : CheckProvDbRegistered
# Desc: Compares the currently registered databases & instances with 
#       the provisioning plan and returns 4 lists:
#         PassedProvDbCheckLL:
#           A list of databases that conform to the provisioning plan.
#         FailedProvDbCheckLL:
#           A list of databases that do not conform to the provisioning 
#           plan (provisioning perspective).
#         PassedRegDbCheckLL
#           Redundant. Should contain the same entries as the 
#             PassedProvDbCheckLL structure.
#         FailedRegDbCheckLL 
#           A list of databases that do not conform to the provisioning 
#           plan (cluster registry perspective).
#
# Args: ProvSchemeDD, RegDbProvSchemeDD
# Retn: PassedProvDbCheckLL,FailedProvDbCheckLL,
#       PassedRegDbCheckLL, FailedRegDbCheckLL
#---------------------------------------------------------------------------
def CheckProvDbRegistered(ProvSchemeDD, RegDbProvSchemeDD):
  PassedProvDbCheckLL  = []
  FailedProvDbCheckLL  = []
  PassedRegDbCheckLL   = []
  FailedRegDbCheckLL   = []

  # We'll take two passes through the ProvSchemeDD and RegDbProvSchemeDD
  # dictionaries. The first one checks provisioned database instances against
  # the registered database instances. The second pass (below) does just the
  # opposite. This catches databases that are provisioned but not registered
  # *and* databases that are registered but not provisioned.
  for ProvDbKey in sorted(ProvSchemeDD.keys()):
    for ProvNodeKey in sorted(ProvSchemeDD[ProvDbKey].keys()):
      if (ProvSchemeDD[ProvDbKey][ProvNodeKey] != ''):           # 'DBFS,DBFS1,enkdb01,enabled,P'
        (ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,ProvFlag)= ProvSchemeDD[ProvDbKey][ProvNodeKey].split(',')
        if (options.StrictMatch):                                # Db Unique Name + Instance Name + State + Node must match
          ProvKey = ProvDbDbUniqueName + ':' + ProvDbInstName + ':' + ProvDbNodeName
        else:                                                    # Db Unique Name + State + Node must match
          ProvKey = ProvDbDbUniqueName + ':' + ProvDbNodeName

        Found = False
        for RegDbKey in sorted(RegDbProvSchemeDD.keys()):                   # for each database
          for RegNodeKey in sorted(RegDbProvSchemeDD[RegDbKey].keys()):     #   for each node
            if (RegDbProvSchemeDD[RegDbKey][RegNodeKey] != ''):  # 'DBFS,DBFS1,enkdb01,enabled'
              (RegDbDbUniqueName,RegDbInstName,RegDbNodeName,RegDbInstState)= RegDbProvSchemeDD[RegDbKey][RegNodeKey].split(',')
              if (options.StrictMatch):
                #print RegDbDbUniqueName + ':' + RegDbInstName  + ':' + RegDbNodeName

                RegKey = RegDbDbUniqueName + ':' + RegDbInstName  + ':' + RegDbNodeName
              else:
                RegKey = RegDbDbUniqueName  + ':' + RegDbNodeName
              if (ProvKey == RegKey):
                Found = True
                TempList = [ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState, RegDbDbUniqueName, RegDbInstName, RegDbNodeName, RegDbInstState]
                if (ProvDbNodeName == RegDbNodeName):
                  if (ProvDbInstState == RegDbInstState):
                    PassedProvDbCheckLL.append(TempList)
                  else:
                    FailedProvDbCheckLL.append(TempList)
                else:
                  FailedProvDbCheckLL.append(TempList)
                break
          if (Found):
            break
        if (not Found):
          FailedProvDbCheckLL.append([ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState, '', '', '', ''])

  # The second pass. See comments above...
  for RegDbKey in sorted(RegDbProvSchemeDD.keys()):
    for RegNodeKey in sorted(RegDbProvSchemeDD[RegDbKey].keys()):
      # 'dbm,dbm1,enkdb03,enabled'
      if (RegDbProvSchemeDD[RegDbKey][RegNodeKey] != ''):
        (RegDbDbUniqueName,RegDbInstName,RegDbNodeName,RegDbInstState)= RegDbProvSchemeDD[RegDbKey][RegNodeKey].split(',')

        ###! RegKey = RegDbDbUniqueName + ':' + RegDbInstName
        if (options.StrictMatch):                                # Db Unique Name + Instance Name + State + Node must match
          RegKey = RegDbDbUniqueName + ':' + RegDbInstName + ':' + RegDbNodeName
        else:                                                    # Db Unique Name + State + Node must match
          RegKey = RegDbDbUniqueName + ':' + RegDbNodeName

        Found = False
        for ProvDbKey in sorted(ProvSchemeDD.keys()):
          for ProvNodeKey in sorted(ProvSchemeDD[ProvDbKey].keys()):
            # 'dbm,dbm1,enkdb03,enabled'
            if (ProvSchemeDD[ProvDbKey][ProvNodeKey] != ''):
              (ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,ProvFlag)= ProvSchemeDD[ProvDbKey][ProvNodeKey].split(',')

              ProvKey = ProvDbDbUniqueName + ':' + ProvDbInstName
              if (options.StrictMatch):                                # Db Unique Name + Instance Name + State + Node must match
                ProvKey = ProvDbDbUniqueName + ':' + ProvDbInstName + ':' + ProvDbNodeName
              else:                                                    # Db Unique Name + State + Node must match
                ProvKey = ProvDbDbUniqueName + ':' + ProvDbNodeName

              if (RegKey == ProvKey):
                Found = True
                TempList = [ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState, RegDbDbUniqueName, RegDbInstName, RegDbNodeName, RegDbInstState]
                if (ProvDbNodeName == RegDbNodeName):       # We've got a match. Now check for a match on the state (enabled/disabled)
                  if (ProvDbInstState == RegDbInstState):
                    ###! try:  # If I've already added this to the PassedRegDbCheckLL then don't append it again.
                    ###!   idx = PassedRegDbCheckLL.index(TempList)
                    ###! except:
                    PassedRegDbCheckLL.append(TempList)
                  else:  # Failed to match instance state
                    ###! try:  # If I've already added this to the PassedRegDbCheckLL then don't append it again.
                    ###!   idx = FailedRegDbCheckLL.index(TempList)
                    ###! except:
                    FailedRegDbCheckLL.append(TempList)
                else:   # Failed to match node name
                  ###! try:  # If I've already added this to the PassedRegDbCheckLL then don't append it again.
                  ###!   idx = FailedRegDbCheckLL.index(TempList)
                  ###! except:
                  FailedRegDbCheckLL.append(TempList)
                break
          if (Found):
            break
        if (not Found):
          FailedRegDbCheckLL.append(['', '', '', '', RegDbDbUniqueName, RegDbInstName, RegDbNodeName, RegDbInstState])

  return(PassedProvDbCheckLL, PassedRegDbCheckLL, FailedProvDbCheckLL, FailedRegDbCheckLL)
# End CheckProvDbRegistered()


# Def : CheckProvSvcRegistered()
# Desc: Compares the currently registered service names with 
#       the provisioning plan and returns 2 lists:
#         PassedProvSvcCheckLL:
#           A list of service names that conform to the provisioning plan.
#         FailedProvSvcCheckLL:
#           A list of service names that do not conform to the provisioning 
#           plan.
# Args: ProvSchemeDD, RegSvcProvSchemeDD
# Retn: PassedProvSvcCheckLL,FailedProvSvcCheckLL
#---------------------------------------------------------------------------
def CheckProvSvcRegistered(ProvSchemeDD, RegSvcProvSchemeDD):
  PassedProvSvcCheckLL = []
  FailedProvSvcCheckLL = []

  for RegSvcKey in sorted(RegSvcProvSchemeDD.keys()):
    for RegNodeKey in sorted(RegSvcProvSchemeDD[RegSvcKey].keys()):
      # 'DBFS,DBFS1,REPORTS,enkdb03,enabled'
      if (RegSvcProvSchemeDD[RegSvcKey][RegNodeKey] != ''):
        (RegSvcDbUniqueName,RegSvcInstName,RegSvcServiceName,RegSvcNodeName,RegSvcServiceState)= RegSvcProvSchemeDD[RegSvcKey][RegNodeKey].split(',')
        RegKey = RegSvcDbUniqueName.upper() + ':' + RegSvcNodeName
        Found = False
        for ProvDbKey in sorted(ProvSchemeDD.keys()):
          for ProvNodeKey in sorted(ProvSchemeDD[ProvDbKey].keys()):
            # 'DBFS,DBFS1,enkdb03,enabled','P'
            if (ProvSchemeDD[ProvDbKey][ProvNodeKey] != ''):
              (ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,ProvFlag)= ProvSchemeDD[ProvDbKey][ProvNodeKey].split(',')
              ProvKey = ProvDbDbUniqueName.upper() + ':' + ProvDbNodeName
              if (RegKey == ProvKey):
                Found = True
                TempList = [ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,RegSvcDbUniqueName,RegSvcInstName,RegSvcServiceName,RegSvcNodeName,RegSvcServiceState]
                if (ProvDbInstState == RegSvcServiceState):
                  try:  # If I've already added this to the PassedProvSvcCheckLL then don't append it again.
                    idx = PassedProvSvcCheckLL.index(TempList)
                    break
                  except:
                    PassedProvSvcCheckLL.append(TempList)
                    break
                else:   # Failed to match instance state
                  try:  # If I've already added this to the PassedProvSvcCheckLL then don't append it again.
                    idx = FailedProvSvcCheckLL.index(TempList)
                    break
                  except:
                    FailedProvSvcCheckLL.append(TempList)
                    break
            if (Found):
              break    # just for performance (quit comparing and go to the next)
          if (Found):
            break      # just for performance (quit comparing and go to the next)
        if (not Found):
          FailedProvSvcCheckLL.append(['', '', '', '', RegSvcDbUniqueName, RegSvcInstName, RegSvcServiceName, RegSvcNodeName, RegSvcServiceState])
  return(PassedProvSvcCheckLL, FailedProvSvcCheckLL)
# End CheckProvSvcRegistered()


# Def : CompareParms()
# Desc: Compares the running database parameters with the values from 
#       the provisioning plan (allowing for a specified tolerance).
# Args: Provisioned: 
#        Parameter (sga_size for example) from the provisioning plan.
#       Actual
#        Parameter (sga_size for example) from the running database.
#       Tolerance
#        Difference allowed between proisioned and actual. 
# Retn: True = actual matches provisioned (within acceptable margin).
#       False = Values are out of tolarance.
#---------------------------------------------------------------------------
def CompareParms(Provisioned, Actual, Tolerance):
  HighThresh = Provisioned + (Provisioned * Tolerance)
  LowThresh  = Provisioned - (Provisioned * Tolerance)

  if (Actual <= HighThresh) and (Actual >= LowThresh):
    return(True)
  else:
    return(False)
# End CompareParms()

# Def : CheckParms()
# Desc: Calls CompareParms() for each parameter in the plan. 
# Args: ProvSchemeDD, RegSvcProvSchemeDD
# Retn: PassedParmsDD:
#        Dictionary of dictionaries containing the databases/parameters
#        are within a tolerable match with the provisioning plan.
#       FailedParmsDD:
#        Dictionary of dictionaries containing the databases/parameters
#        failed to be within tolerable match with the provisioning plan.
#---------------------------------------------------------------------------
def CheckParms(ProvisionedDD, RunningDbInfoDD):
  PassedParmsDD = {}
  FailedParmsDD = {}

  for DbUniqueName in sorted(ProvisionedDD.keys()):
    if (DbUniqueName in list(RunningDbInfoDD.keys())):
      ProvPgaAggregateTarget   = ProvisionedDD[DbUniqueName]['pga_aggregate_target'  ]
      ProvSharedPoolSize       = ProvisionedDD[DbUniqueName]['shared_pool_size'      ]
      ProvSgaMaxSize           = ProvisionedDD[DbUniqueName]['sga_max_size'          ]
      ProvSgaTarget            = ProvisionedDD[DbUniqueName]['sga_target'            ]
      ProvMemoryMaxTarget      = ProvisionedDD[DbUniqueName]['memory_max_target'     ]
      ProvMemoryTarget         = ProvisionedDD[DbUniqueName]['memory_target'         ]
      ProvTotalStorage         = ProvisionedDD[DbUniqueName]['total_storage'         ]

      ActualPgaAggregateTarget = RunningDbInfoDD[DbUniqueName]['pga_aggregate_target']
      ActualSharedPoolSize     = RunningDbInfoDD[DbUniqueName]['shared_pool_size'    ]
      ActualSgaMaxSize         = RunningDbInfoDD[DbUniqueName]['sga_max_size'        ]
      ActualSgaTarget          = RunningDbInfoDD[DbUniqueName]['sga_target'          ]
      ActualMemoryMaxTarget    = RunningDbInfoDD[DbUniqueName]['memory_max_target'   ]
      ActualMemoryTarget       = RunningDbInfoDD[DbUniqueName]['memory_target'       ]
      ActualTotalStorage       = RunningDbInfoDD[DbUniqueName]['total_storage'       ]
        
      PassedParmsDict = {}
      FailedParmsDict = {}

      # Compare Actual with Provisioned. A 10% variance is acceptible.
      if (ProvPgaAggregateTarget == ActualPgaAggregateTarget):
        PassedParmsDict['pga_aggregate_target'] = [ProvPgaAggregateTarget, ActualPgaAggregateTarget]
      else:
        if (ProvPgaAggregateTarget == '' or ActualPgaAggregateTarget == ''):
          FailedParmsDict['pga_aggregate_target'] = [ProvPgaAggregateTarget, ActualPgaAggregateTarget]
        else:
            ProvPgaAggregateTarget   = int(ProvPgaAggregateTarget)  
            ActualPgaAggregateTarget = int(ActualPgaAggregateTarget)
            if (CompareParms(int(ProvPgaAggregateTarget), int(ActualPgaAggregateTarget), .1)):
              PassedParmsDict['pga_aggregate_target'] = [ProvPgaAggregateTarget, ActualPgaAggregateTarget]
            else:
              FailedParmsDict['pga_aggregate_target'] = [ProvPgaAggregateTarget, ActualPgaAggregateTarget]

      if (ProvSharedPoolSize == ActualSharedPoolSize):
        PassedParmsDict['shared_pool_size'] = [ProvSharedPoolSize, ActualSharedPoolSize]
      else:
        if (ProvSharedPoolSize == '' or ActualSharedPoolSize == ''):
          FailedParmsDict['shared_pool_size'] = [ProvSharedPoolSize, ActualSharedPoolSize]
        else:
            ProvSharedPoolSize   = int(ProvSharedPoolSize)  
            ActualSharedPoolSize = int(ActualSharedPoolSize)
            if (CompareParms(int(ProvSharedPoolSize), int(ActualSharedPoolSize), .1)):
              PassedParmsDict['shared_pool_size'] = [ProvSharedPoolSize, ActualSharedPoolSize]
            else:
              FailedParmsDict['shared_pool_size'] = [ProvSharedPoolSize, ActualSharedPoolSize]

      if (ProvSgaMaxSize == ActualSgaMaxSize):
        PassedParmsDict['sga_max_size'] = [ProvSgaMaxSize, ActualSgaMaxSize]
      else:
        if (ProvSgaMaxSize == '' or ActualSgaMaxSize == ''):
          FailedParmsDict['sga_max_size'] = [ProvSgaMaxSize, ActualSgaMaxSize]
        else:
            ProvSgaMaxSize   = int(ProvSgaMaxSize)  
            ActualSgaMaxSize = int(ActualSgaMaxSize)
            if (CompareParms(int(ProvSgaMaxSize), int(ActualSgaMaxSize), .1)):
              PassedParmsDict['sga_max_size'] = [ProvSgaMaxSize, ActualSgaMaxSize]
            else:
              FailedParmsDict['sga_max_size'] = [ProvSgaMaxSize, ActualSgaMaxSize]

      if (ProvSgaTarget == ActualSgaTarget):
        PassedParmsDict['sga_target'] = [ProvSgaTarget, ActualSgaTarget]
      else:
        if (ProvSgaTarget == '' or ActualSgaTarget == ''):
          FailedParmsDict['sga_target'] = [ProvSgaTarget, ActualSgaTarget]
        else:
            ProvSgaTarget   = int(ProvSgaTarget)  
            ActualSgaTarget = int(ActualSgaTarget)
            if (CompareParms(int(ProvSgaTarget), int(ActualSgaTarget), .1)):
              PassedParmsDict['sga_target'] = [ProvSgaTarget, ActualSgaTarget]
            else:
              FailedParmsDict['sga_target'] = [ProvSgaTarget, ActualSgaTarget]

      if (ProvMemoryMaxTarget == ActualMemoryMaxTarget):
        PassedParmsDict['memory_max_target'] = [ProvMemoryMaxTarget, ActualMemoryMaxTarget]
      else:
        if (ProvMemoryMaxTarget == '' or ActualMemoryMaxTarget == ''):
          FailedParmsDict['memory_max_target'] = [ProvMemoryMaxTarget, ActualMemoryMaxTarget]
        else:
            ProvMemoryMaxTarget   = int(ProvMemoryMaxTarget)  
            ActualMemoryMaxTarget = int(ActualMemoryMaxTarget)
            if (CompareParms(int(ProvMemoryMaxTarget), int(ActualMemoryMaxTarget), .1)):
              PassedParmsDict['memory_max_target'] = [ProvMemoryMaxTarget, ActualMemoryMaxTarget]
            else:
              FailedParmsDict['memory_max_target'] = [ProvMemoryMaxTarget, ActualMemoryMaxTarget]

      if (ProvMemoryTarget == ActualMemoryTarget):
        PassedParmsDict['memory_target'] = [ProvMemoryTarget, ActualMemoryTarget]
      else:
        if (ProvMemoryTarget == '' or ActualMemoryTarget == ''):
          FailedParmsDict['memory_target'] = [ProvMemoryTarget, ActualMemoryTarget]
        else:
            ProvMemoryTarget   = int(ProvMemoryTarget)  
            ActualMemoryMaxTarget = int(ActualMemoryTarget)
            if (CompareParms(int(ProvMemoryTarget), int(ActualMemoryTarget), .1)):
              PassedParmsDict['memory_target'] = [ProvMemoryTarget, ActualMemoryTarget]
            else:
              FailedParmsDict['memory_target'] = [ProvMemoryTarget, ActualMemoryTarget]

      if (ProvTotalStorage == ActualTotalStorage):
        PassedParmsDict['total_storage'] = [ProvTotalStorage, ActualTotalStorage]
      else:
        if (ProvTotalStorage == '' or ActualTotalStorage == ''):
          FailedParmsDict['total_storage'] = [ProvTotalStorage, ActualTotalStorage]
        else:
            ProvMemoryTarget   = int(ProvTotalStorage)  
            ActualTotalStorage = int(ActualTotalStorage)
            if (CompareParms(int(ProvTotalStorage), int(ActualTotalStorage), .1)):
              PassedParmsDict['total_storage'] = [ProvTotalStorage, ActualTotalStorage]
            else:
              FailedParmsDict['total_storage'] = [ProvTotalStorage, ActualTotalStorage]

      # Stuff passed/failed parameters into dictionary structures and move on to the next database.
      if (len(PassedParmsDict)):
      	PassedParmsDD[DbUniqueName] = PassedParmsDict

      if (len(FailedParmsDict)):
      	FailedParmsDD[DbUniqueName] = FailedParmsDict

  return(PassedParmsDD, FailedParmsDD)
# End CheckParms()


# Def : RunSqlplus()
# Desc: Executes sqlplus and runs a passed-in set of sql statements. Checks
#       the output for errors and returns the results in simple string 
#       format. If an error is generated from sqlplus then the error is 
#       formatted, printed, and the program exits with the return code.
# Args: DbUser, DbPassword, ConnectString, SqlStmt
# Retn: SqlplusOut: a simple string containing the output from sqlplus 
#       (stdout).
#---------------------------------------------------------------------------
def RunSqlplus(DbUser, DbPassword, ConnectString, SqlStmt):
  ConnStr = DbUser + '/' + DbPassword + '@' + ConnectString

  # Start Sqlplus and login
  if (DbUser.upper() == 'SYS'):
    hSqlplus = Popen([Sqlplus, '-s', ConnStr, 'AS', 'SYSDBA'], bufsize=1, stdin=PIPE, stdout=PIPE, \
     stderr=STDOUT, shell=False, universal_newlines=True, close_fds=True)
  else:
    hSqlplus = Popen([Sqlplus, '-s', ConnStr], bufsize=1, stdin=PIPE, stdout=PIPE, \
     stderr=STDOUT, shell=False, universal_newlines=True, close_fds=True)

  # Run the query
  hSqlplus.stdin.write(SqlStmt)

  # fetch the output
  SqlplusOut, SqlplusErr = hSqlplus.communicate()

  # Check for sqlplus errors
  (rc, ErrorStack) = ErrorCheck(SqlplusOut)
  if (rc != 0):
    PrintError(ErrorStack)
    exit(rc)

  return(SqlplusOut)
# End RunSqlplus()

# Def : PrintError()
# Desc: Print a formatted error message.
# Args: ErrorMsg (the error message to be printed)
# Retn: None
#---------------------------------------------------------------------------
def PrintError(ErrorMsg):
  print('\n>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<')
  for line in ErrorMsg:
    print(line)
  print('>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>><<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n')
  return
# End PrintError()


# Def : SetOracleEnv()
# Desc: Setup your environemnt (ORACLE_HOME, ORACLE_SID)
# Args: Sid = The ORACLE_SID of the home you want to configure for 
#       (parses oratab file).
# Retn: OracleHome = $ORACLE_HOME
#---------------------------------------------------------------------------
def SetOracleEnv(Sid):
  OracleSid = ''
  OracleHome = ''

  try:
    Oratab = open(OratabFile)
  except:
    formatExceptionInfo()
    print('Cannot open oratab file: ' + OratabFile + ' for read.')
    exit(1)

  OratabContents = Oratab.read().split('\n')
  for line in OratabContents:
    if ((line.find(Sid, 0, len(Sid)))) >= 0:
      (OracleSid, OracleHome, junk) = line.split(':')
    if (OracleSid != ''):
      environ['ORACLE_SID']   = OracleSid
      environ['ORACLE_HOME']  = OracleHome
  return(OracleHome)
# End SetOracleEnv()

# Def : ErrorCheck()
# Desc: Check sqlplus, crsctl, srvctl output for errors.
# Args: Output(output you want to scan for errors)
# Retn: Returns 0=no errors or 1=error found, and error stack
#-------------------------------------------------------------------------
def ErrorCheck(Output):
  ErrorStack = []
  rc         = 0

  for line in Output.split('\n'):
    # Check for warning and error messages
    if ((line.find('ERROR:', 0, 6) >= 0) or \
        (line.find('ORA-',   0, 4) >= 0) or \
        (line.find('SP2-',   0, 4) >= 0)):
      rc = 1
      ErrorStack.append(line)
  return(rc, ErrorStack)
# End ErrorCheck()

# Def : FindInList()
# Desc: My implementation of a search function for Lists.
# Args: SearchString, SearchList
# Retn: Returns 0=not found 1=found
#---------------------------------------------------------------------------
def FindInList(SearchString, SearchList):
  for i in SearchList:
    if (i.find(SearchString) >= 0):
      return(1)
  return(0)
# End FindInList()

# Def : GetNodeId()
# Desc: Takes a cluster node name and returns the node id.
# Args: NodeName (one of the node names returned by olsnodes)
# Retn: Returns 0'not found 1..n=NodeId
#---------------------------------------------------------------------------
def GetNodeId(NodeName):
  for NodeDict in RegisteredNodeListOfDict:
    if NodeDict['NodeName'] == NodeName:
      return(NodeDict['NodeId'])
  return('0')
# End GetNodeId()

# Def GetNodeName()
# Desc: Takes a cluster node id and returns the node name.
# Args: NodeId (one of the node ID's returned by olsnodes)
# Retn: Returns 0=not found -or- NodeName
#---------------------------------------------------------------------------
def GetNodeName(NodeId):
  for NodeDict in RegisteredNodeListOfDict:
    if NodeDict['NodeId'] == NodeId:
      return(NodeDict['NodeName'])
  return('0')
# End of GetNodeName()

# Def GetNodeName()
# Desc: Prints a dump of the DatabaseConfigList variable.
# Args: DatabaseConfigList
# Retn: 
#---------------------------------------------------------------------------
def PrintImportedConfig(DatabaseConfigList):
  print('\n----------------------------------------------------------')
  print('-- Provisioning Plan from improv.csv ---------------------')
  print('----------------------------------------------------------')
  FirstLoop = True
  for key in sorted(ImpDD):
    if (not FirstLoop):
      print('  ---')
    print('  [' + ImpDD[key]['db_unique_name'] + ']')
    print('  db_unique_name       = ' + ImpDD[key]['db_unique_name'])
    print('  db_name              = ' + ImpDD[key]['db_name'])
    print('  pga_aggregate_target = ' + ImpDD[key]['pga_aggregate_target'])
    print('  sga_max_size         = ' + ImpDD[key]['sga_max_size'])
    print('  sga_target           = ' + ImpDD[key]['sga_target'])
    print('  memory_max_target    = ' + ImpDD[key]['memory_max_target'])
    print('  memory_target        = ' + ImpDD[key]['memory_target'])
    print('  total_storage        = ' + ImpDD[key]['total_storage'])
    print('  node1                = ' + ImpDD[key]['node1'])
    print('  node2                = ' + ImpDD[key]['node2'])
    print('  node3                = ' + ImpDD[key]['node3'])
    print('  node4                = ' + ImpDD[key]['node4'])
    print('  node5                = ' + ImpDD[key]['node5'])
    print('  node6                = ' + ImpDD[key]['node6'])
    print('  node7                = ' + ImpDD[key]['node7'])
    print('  node8                = ' + ImpDD[key]['node8'])
    FirstLoop = False
  print('----------------------------------------------------------')
  print('-- End of Report: Provisioning Plan from improv.csv ------')
  print('----------------------------------------------------------\n')
  return
# End PrintImportedConfig()


# Def GetNodeName()
# Desc: Prints a dump of the RegisteredDbDD variable.
# Args: RegisteredDbDD
# Retn: 
#---------------------------------------------------------------------------
def PrintRegisteredDbDD(RegisteredDbDD):
  print('\n---------------------------------------------------------------------------------------------------------------')
  print('-- Registered Database Resource Attributes --------------------------------------------------------------------')
  print('---------------------------------------------------------------------------------------------------------------')
  FirstLoop = True
  for DbKey in sorted(RegisteredDbDD.keys()):
    if (not FirstLoop):
      print('  ---')
    print('  Name                            = ' + RegisteredDbDD[DbKey]['Name'])
    print('  Type                            = ' + RegisteredDbDD[DbKey]['Type'])
    print('  DbUniqueName                    = ' + RegisteredDbDD[DbKey]['DbUniqueName'])
    print('  UsrOraDbName                    = ' + RegisteredDbDD[DbKey]['UsrOraDbName'])
    print('  Version                         = ' + RegisteredDbDD[DbKey]['Version'])
    print('  DatabaseType                    = ' + RegisteredDbDD[DbKey]['DatabaseType'])
    print('  ClusterDatabase                 = ' + RegisteredDbDD[DbKey]['ClusterDatabase'])
    print('  AutoStart                       = ' + RegisteredDbDD[DbKey]['AutoStart'])
    print('  UsrOraStopMode                  = ' + RegisteredDbDD[DbKey]['UsrOraStopMode'])
    print('  UsrOraOpenMode                  = ' + RegisteredDbDD[DbKey]['UsrOraOpenMode'])
    print('  Enabled                         = ' + RegisteredDbDD[DbKey]['Enabled'])
    print('  Spfile                          = ' + RegisteredDbDD[DbKey]['Spfile'])
    print('  OracleHome                      = ' + RegisteredDbDD[DbKey]['OracleHome'])
    print('  GenStartOptionsServernameList   = ' + repr(RegisteredDbDD[DbKey]['GenStartOptionsServernameList']))
    print('  UsrOraInstNameServernameList    = ' + repr(RegisteredDbDD[DbKey]['UsrOraInstNameServernameList']))
    FirstLoop = False
  print('---------------------------------------------------------------------------------------------------------------')
  print('-- End of Report: Registered Database Resource Attributes -----------------------------------------------------')
  print('---------------------------------------------------------------------------------------------------------------\n')
  return
# End PrintRegisteredDbDD()


# Def : PrintRegisteredSvcDD()
# Desc: Prints a dump of the RegisteredSvcDD variable.
# Args: RegisteredSvcDD
# Retn: 
#---------------------------------------------------------------------------
def PrintRegisteredSvcDD(RegisteredSvcDD):
  print('\n----------------------------------------------------------------------------------')
  print('-- Registered Service Name Attributes --------------------------------------------')
  print('----------------------------------------------------------------------------------')
  FirstLoop = True
  for DbKey in list(RegisteredSvcDD.keys()):
    if (not FirstLoop):
      print('  ---')
    print('  Name                           = ' + RegisteredSvcDD[DbKey]['Name'])
    print('  Type                           = ' + RegisteredSvcDD[DbKey]['Type'])
    print('  ServiceName                    = ' + RegisteredSvcDD[DbKey]['ServiceName'])
    print('  ServerPools                    = ' + RegisteredSvcDD[DbKey]['ServerPools'])
    print('  EnabledServernameList          = ' + repr(RegisteredSvcDD[DbKey]['EnabledServernameList']))
    print('  Role                           = ' + RegisteredSvcDD[DbKey]['Role'])
    print('  TafPolicy                      = ' + RegisteredSvcDD[DbKey]['TafPolicy'])
    print('  Version                        = ' + RegisteredSvcDD[DbKey]['Version'])
    print('  Enabled                        = ' + RegisteredSvcDD[DbKey]['Enabled'])
    print('  AutoStart                      = ' + RegisteredSvcDD[DbKey]['AutoStart'])
    print('  RestartAttempts                = ' + RegisteredSvcDD[DbKey]['RestartAttempts'])
    print('  ManagementPolicy               = ' + RegisteredSvcDD[DbKey]['ManagementPolicy'])
    print('  ClbGoal                        = ' + RegisteredSvcDD[DbKey]['ClbGoal'])
    print('  RlbGoal                        = ' + RegisteredSvcDD[DbKey]['RlbGoal'])
    print('  FailoverType                   = ' + RegisteredSvcDD[DbKey]['FailoverType'])
    print('  FailoverMethod                 = ' + RegisteredSvcDD[DbKey]['FailoverMethod'])
    print('  FailoverRetries                = ' + RegisteredSvcDD[DbKey]['FailoverRetries'])
    print('  UsrOraDisconnect               = ' + RegisteredSvcDD[DbKey]['UsrOraDisconnect'])
    print('  UsrOraOpi                      = ' + RegisteredSvcDD[DbKey]['UsrOraOpi'])
    FirstLoop = False
  print('--------------------------------------------------------------------------------')
  print('-- End of Report: Registered Service Name Attributes ---------------------------')
  print('--------------------------------------------------------------------------------\n')
  return
# End RegisteredSvcDD


# Def : PrintProvisionedDD()
# Desc: Prints a dump of the ProvisionedDD variable.
# Args: ProvisionedDD
# Retn: 
#---------------------------------------------------------------------------
def PrintProvisionedDD(ProvisionedDD):
  print('\n------------------------------------------------------------------------------------------------------------')
  print('-- Provisioning Scheme from improv.ini ---------------------------------------------------------------------')
  print('------------------------------------------------------------------------------------------------------------')
  FirstLoop = True
  for DbKey in list(ProvisionedDD.keys()):
    if (not FirstLoop):
      print('  ---')
    # sqlplus sys/welcome@td01-scan.tnd.us.cbre.net:1521/dbm as sysdba
    EZConnect  = 'sqlplus '
    EZConnect += ProvisionedDD[DbKey]['user_name']
    EZConnect += '/'
    EZConnect += ProvisionedDD[DbKey]['password']
    EZConnect += '@'
    EZConnect += ProvisionedDD[DbKey]['host']
    EZConnect += ':'
    EZConnect += ProvisionedDD[DbKey]['port']
    EZConnect += '/'
    EZConnect += ProvisionedDD[DbKey]['service_name']
    if (upper(ProvisionedDD[DbKey]['user_name']) == 'SYS'):
      EZConnect += ' as sysdba'
    print('  [' + ProvisionedDD[DbKey]['db_unique_name'] + ']')
    print('  EZConnect            = ' + EZConnect)
    print('  db_unique_name       = ' + ProvisionedDD[DbKey]['db_unique_name'])
    print('  db_name              = ' + ProvisionedDD[DbKey]['db_name'])
    print('  user_name            = ' + ProvisionedDD[DbKey]['user_name'])
    print('  password             = ' + ProvisionedDD[DbKey]['password'])
    print('  host                 = ' + ProvisionedDD[DbKey]['host'])
    print('  port                 = ' + ProvisionedDD[DbKey]['port'])
    print('  service_name         = ' + ProvisionedDD[DbKey]['service_name'])
    print('  password             = ' + ProvisionedDD[DbKey]['password'])
    print('  db_cache_size        = ' + ProvisionedDD[DbKey]['db_cache_size'])
    print('  java_pool_size       = ' + ProvisionedDD[DbKey]['java_pool_size'])
    print('  large_pool_size      = ' + ProvisionedDD[DbKey]['large_pool_size'])
    print('  shared_pool_size     = ' + ProvisionedDD[DbKey]['shared_pool_size'])
    print('  streams_pool_size    = ' + ProvisionedDD[DbKey]['streams_pool_size'])
    print('  pga_aggregate_target = ' + ProvisionedDD[DbKey]['pga_aggregate_target'])
    print('  sga_max_size         = ' + ProvisionedDD[DbKey]['sga_max_size'])
    print('  sga_target           = ' + ProvisionedDD[DbKey]['sga_target'])
    print('  memory_max_target    = ' + ProvisionedDD[DbKey]['memory_max_target'])
    print('  memory_target        = ' + ProvisionedDD[DbKey]['memory_target'])
    print('  datafile_bytes       = ' + ProvisionedDD[DbKey]['datafile_bytes'])
    print('  tempfile_bytes       = ' + ProvisionedDD[DbKey]['tempfile_bytes'])
    print('  redofile_bytes       = ' + ProvisionedDD[DbKey]['redofile_bytes'])
    print('  controlfile_bytes    = ' + ProvisionedDD[DbKey]['controlfile_bytes'])
    print('  total_storage        = ' + ProvisionedDD[DbKey]['total_storage'])
    print('  node1                = ' + ProvisionedDD[DbKey]['node1'])
    print('  node2                = ' + ProvisionedDD[DbKey]['node2'])
    print('  node3                = ' + ProvisionedDD[DbKey]['node3'])
    print('  node4                = ' + ProvisionedDD[DbKey]['node4'])
    print('  node5                = ' + ProvisionedDD[DbKey]['node5'])
    print('  node6                = ' + ProvisionedDD[DbKey]['node6'])
    print('  node7                = ' + ProvisionedDD[DbKey]['node7'])
    print('  node8                = ' + ProvisionedDD[DbKey]['node8'])
    FirstLoop = False
  print('------------------------------------------------------------------------------------------------------------')
  print('-- End of Report: Provisioning Scheme from improv.ini ------------------------------------------------------')
  print('------------------------------------------------------------------------------------------------------------\n')
  return
# End PrintProvisionedDD

# Def : ReportDatabaseInfo()
# Desc: Prints a detailed report of database configuration information.
# Args: RunningDbInfoDD
# Retn: 
#---------------------------------------------------------------------------
def ReportDatabaseInfo(RunningDbInfoDD):

  print('----------------------------------------------------------------------------------------------------------')
  print('-- Database Configuration Report -------------------------------------------------------------------------')
  print('----------------------------------------------------------------------------------------------------------')

  FirstLoop = True
  for DbUniqueName in sorted(RunningDbInfoDD.keys()):
    memory_max_target = int(RunningDbInfoDD[DbUniqueName]['memory_max_target'])
    memory_target     = int(RunningDbInfoDD[DbUniqueName]['memory_target'])
    sga_max_size      = int(RunningDbInfoDD[DbUniqueName]['sga_max_size'])
    sga_target        = int(RunningDbInfoDD[DbUniqueName]['sga_target'])
    shared_pool_size  = int(RunningDbInfoDD[DbUniqueName]['shared_pool_size'])
    statistics_level  = RunningDbInfoDD[DbUniqueName]['statistics_level'].lower()

    if (memory_max_target > 0 and memory_target > 0):
      MemoryManagement = 'AMM'
    #elif (sga_max_size > 0 and sga_target > 0 and shared_pool_size > 0 and (statistics_level == 'typical' or statistics_level == 'all')):
    elif (sga_target > 0 and (statistics_level == 'typical' or statistics_level == 'all')):
      MemoryManagement = 'ASMM'
    else:
      MemoryManagement = 'Manual'

    db_name                    = RunningDbInfoDD[DbUniqueName]['db_name']
    db_unique_name             = RunningDbInfoDD[DbUniqueName]['db_unique_name']
    db_domain                  = RunningDbInfoDD[DbUniqueName]['db_domain']
    db_version                 = RunningDbInfoDD[DbUniqueName]['db_version']
    resource_manager_plan      = RunningDbInfoDD[DbUniqueName]['resource_manager_plan']
    cpu_count                  = RunningDbInfoDD[DbUniqueName]['cpu_count']
    _kill_diagnostics_timeout  = RunningDbInfoDD[DbUniqueName]['_kill_diagnostics_timeout']
    _lm_rcvr_hang_allow_time   = RunningDbInfoDD[DbUniqueName]['_lm_rcvr_hang_allow_time']
    instance_name              = RunningDbInfoDD[DbUniqueName]['instance_name']
    statistics_level           = RunningDbInfoDD[DbUniqueName]['statistics_level']
    db_create_file_dest        = RunningDbInfoDD[DbUniqueName]['db_create_file_dest']
    db_recovery_file_dest      = RunningDbInfoDD[DbUniqueName]['db_recovery_file_dest']
    db_recovery_file_dest_size = splitThousands(RunningDbInfoDD[DbUniqueName]['db_recovery_file_dest_size'] )
    memory_max_target          = splitThousands(RunningDbInfoDD[DbUniqueName]['memory_max_target']          )
    memory_target              = splitThousands(RunningDbInfoDD[DbUniqueName]['memory_target']              )
    sga_max_size               = splitThousands(RunningDbInfoDD[DbUniqueName]['sga_max_size']               )
    sga_target                 = splitThousands(RunningDbInfoDD[DbUniqueName]['sga_target']                 )
    pga_aggregate_target       = splitThousands(RunningDbInfoDD[DbUniqueName]['pga_aggregate_target']       )
    db_cache_size              = splitThousands(RunningDbInfoDD[DbUniqueName]['db_cache_size']              )
    shared_pool_size           = splitThousands(RunningDbInfoDD[DbUniqueName]['shared_pool_size']           )
    streams_pool_size          = splitThousands(RunningDbInfoDD[DbUniqueName]['streams_pool_size']          )
    large_pool_size            = splitThousands(RunningDbInfoDD[DbUniqueName]['large_pool_size']            )
    java_pool_size             = splitThousands(RunningDbInfoDD[DbUniqueName]['java_pool_size']             )
    current_sga_usage          = splitThousands(RunningDbInfoDD[DbUniqueName]['current_sga_usage']          )
    tempfile_bytes             = splitThousands(RunningDbInfoDD[DbUniqueName]['tempfile_bytes']             )
    redofile_bytes             = splitThousands(RunningDbInfoDD[DbUniqueName]['redofile_bytes']             )
    controlfile_bytes          = splitThousands(RunningDbInfoDD[DbUniqueName]['controlfile_bytes']          )
    total_storage              = splitThousands(RunningDbInfoDD[DbUniqueName]['total_storage']              )
    datafile_bytes             = splitThousands(RunningDbInfoDD[DbUniqueName]['datafile_bytes']             )
    tempfile_bytes             = splitThousands(RunningDbInfoDD[DbUniqueName]['tempfile_bytes']             )
    controlfile_bytes          = splitThousands(RunningDbInfoDD[DbUniqueName]['controlfile_bytes']          )
    redofile_bytes             = splitThousands(RunningDbInfoDD[DbUniqueName]['redofile_bytes']             )
    if (not FirstLoop):
      print('\n  --------------------------------------------------------------------------------------------------------\n')

    # Extract the database version from: "Oracle Database 11g Enterprise Edition Release 11.2.0.3.0 - 64bit Production"
    db_version = db_version[db_version.find('Release')+8:]
    db_version = db_version.split(' ')[0]

    print('  General Information:                                Exadata Recommended Parameters:')
    print('   %-26s = %18s     %-26s = %18s' % ('instance_name',  instance_name, '_kill_diagnostics_timeout', _kill_diagnostics_timeout))
    print('   %-26s = %18s     %-26s = %18s' % ('db_version',     db_version,    '_lm_rcvr_hang_allow_time',  _lm_rcvr_hang_allow_time ))
    print('   %-26s = %18s'                  % ('db_name',        db_name                                                              ))
    print('   %-26s = %18s'                  % ('db_unique_name', db_unique_name                                                       ))
    print('   %-26s = %18s'                  % ('db_domain',      db_domain                                                            ))
    print('')
    print('  Memory Configuration:                               Memory Pool Sizes:')
    print('   %-26s = %18s     %-26s = %18s' % ('Memory Management',    MemoryManagement,     'db_cache_size',     db_cache_size     ))
    print('   %-26s = %18s     %-26s = %18s' % ('statistics_level',     statistics_level,     'shared_pool_size',  shared_pool_size  ))
    print('   %-26s = %18s     %-26s = %18s' % ('sga_target',           sga_target,           'streams_pool_size', streams_pool_size ))
    print('   %-26s = %18s     %-26s = %18s' % ('sga_max_size',         sga_max_size,         'large_pool_size',   large_pool_size   ))
    print('   %-26s = %18s     %-26s = %18s' % ('memory_target',        memory_target,        'java_pool_size',    java_pool_size    ))
    print('   %-26s = %18s     %-26s = %18s' % ('memory_max_target',    memory_max_target,    'current_sga_usage', current_sga_usage ))
    print('   %-26s = %18s                 ' % ('pga_aggregate_target', pga_aggregate_target))
    print('')
    print('  Storage Configuration:                              Storage Utilization:')
    print('   %-26s = %18s     %-26s = %18s' % ('db_create_file_dest',        db_create_file_dest,        'Datafiles',       datafile_bytes   ))
    print('   %-26s = %18s     %-26s = %18s' % ('db_recovery_file_dest',      db_recovery_file_dest,      'Tempfiles',       tempfile_bytes   ))
    print('   %-26s = %18s     %-26s = %18s' % ('db_recovery_file_dest_size', db_recovery_file_dest_size, 'Redologs',        redofile_bytes   ))
    print('   %-26s   %18s     %-26s = %18s' % ('',                           '',                         'Controlfiles',    controlfile_bytes))
    print('   %-26s   %18s     %-26s = %18s' % ('',                           '',                         'Total Storage',   total_storage    ))
    print('')
    print('  Resource Management:')
    print('   %-26s = %18s' % ('cpu_count',             cpu_count            ))
    print('   %-26s = %18s' % ('resource_manager_plan', resource_manager_plan))
    FirstLoop = False
  print('----------------------------------------------------------------------------------------------------------')
  print('-- End of Report: Database Configuration Report ----------------------------------------------------------')
  print('----------------------------------------------------------------------------------------------------------')
  return
# End ReportDatabaseInfo()


# Def : PrintRunningDbInfoDD()
# Desc: Prints a dump of the RunningDbInfoDD variable.
# Args: RunningDbInfoDD
# Retn: 
#---------------------------------------------------------------------------
def PrintRunningDbInfoDD(RunningDbInfoDD):
  print('\n---------------------------------------------------------------')
  print('-- Active Database Parameters ---------------------------------')
  print('---------------------------------------------------------------')
  FirstLoop = True
  print('  Database Parameter           Value')
  print('  ---------------------------  ------------------------------')
  for DbKey in list(RunningDbInfoDD.keys()):
    if (not FirstLoop):
      print('  ---')
    print('  db_name                      ' + RunningDbInfoDD[DbKey]['db_name'])
    print('  db_unique_name               ' + RunningDbInfoDD[DbKey]['db_unique_name'])
    print('  pga_aggregate_target         ' + RunningDbInfoDD[DbKey]['pga_aggregate_target'])
    print('  db_cache_size                ' + RunningDbInfoDD[DbKey]['db_cache_size'])
    print('  shared_pool_size             ' + RunningDbInfoDD[DbKey]['shared_pool_size'])
    print('  streams_pool_size            ' + RunningDbInfoDD[DbKey]['streams_pool_size'])
    print('  large_pool_size              ' + RunningDbInfoDD[DbKey]['large_pool_size'])
    print('  java_pool_size               ' + RunningDbInfoDD[DbKey]['java_pool_size'])
    print('  datafile_bytes               ' + RunningDbInfoDD[DbKey]['datafile_bytes'])
    print('  tempfile_bytes               ' + RunningDbInfoDD[DbKey]['tempfile_bytes'])
    print('  redofile_bytes               ' + RunningDbInfoDD[DbKey]['redofile_bytes'])
    print('  controlfile_bytes            ' + RunningDbInfoDD[DbKey]['controlfile_bytes'])
    print('  total_storage                ' + RunningDbInfoDD[DbKey]['total_storage'])
    print('  sga_max_size                 ' + RunningDbInfoDD[DbKey]['sga_max_size'])
    print('  sga_target                   ' + RunningDbInfoDD[DbKey]['sga_target'])
    print('  memory_max_target            ' + RunningDbInfoDD[DbKey]['memory_max_target'])
    print('  memory_target                ' + RunningDbInfoDD[DbKey]['memory_target'])
    print('  current_sga_usage            ' + RunningDbInfoDD[DbKey]['current_sga_usage'])
    print('  shared_pool_size             ' + RunningDbInfoDD[DbKey]['shared_pool_size'])
    print('  db_recovery_file_dest        ' + RunningDbInfoDD[DbKey]['db_recovery_file_dest'])
    print('  db_recovery_file_dest_size   ' + RunningDbInfoDD[DbKey]['db_recovery_file_dest_size'])
    FirstLoop = False
  print('---------------------------------------------------------------')
  print('-- End of Report: Active Database Parameters ------------------')
  print('---------------------------------------------------------------\n')
  return
# End PrintRunningDbInfoDD()

# Def : ReportPassedProvDbCheck()
# Desc: Prints a Database provisioning report showing the succefully 
#       provisioned databases.
# Args: PassedProvDbCheckLL
# Retn: 
#---------------------------------------------------------------------------
def ReportPassedProvDbCheck(PassedProvDbCheckLL):
  PageSize = 50
  PageNum  = 1
  if (len(PassedProvDbCheckLL) == 0):
    print('\nEither no provisioned instances defined in improv.ini file')
    print('or no properly provisioned instances found.')
  else:
    ItemNum = 0
    PrintHeader = True
    for Item in PassedProvDbCheckLL:
      ItemNum += 1
      if (PrintHeader):
        PrintHeader = False
        print('\n\nInstances Properly Provisioned (pg ' + str(PageNum) + ')')
        PageNum += 1
        print('-------------------------------------')
        print('')
        print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')
        print('    |                                                      | |                                                             |')
        print('###  Db Unique Name  Instance      Node            State       Db Unique Name    Instance        Node              State')
        print('---  --------------- ------------- --------------- --------    ----------------  --------------  ----------------  --------')

      ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,RegDbDbUniqueName,RegDbInstName, \
       RegDbNodeName,RegDbInstState = Item

      print('%3s  %-15s %-13s %-15s %-8s    %-15s   %-13s   %-15s   %-8s' % (ItemNum,ProvDbDbUniqueName,ProvDbInstName, \
       ProvDbNodeName,ProvDbInstState,RegDbDbUniqueName,RegDbInstName,RegDbNodeName,RegDbInstState))

      if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
        PrintHeader = True
        print('    |                                                      | |                                                             |')
        print('    +-- Provisioned ---------------------------------------+ +--Registered ------------------------------------------------+')

  if (not PrintHeader):  # Print the footer one last time before exiting.
    print('    |                                                      | |                                                             |')
    print('    +-- Provisioned ---------------------------------------+ +--Registered ------------------------------------------------+')
  return
# End ReportPassedProvDbCheck()

# Def : ReportFailedProvDbCheck()
# Desc: Prints a Database provisioning report showing that were not 
#       correctly provisioned.
# Args: FailedProvDbCheckLL
# Retn: 
#---------------------------------------------------------------------------
def ReportFailedProvDbCheck(FailedProvDbCheckLL):
  PageSize    = 50
  PageNum     = 1
  PrintHeader = True

  if (len(FailedProvDbCheckLL) == 0):
    print('\n\nAll instances provisioned according to plan (Plan View)')
  else:
    ItemNum = 0
    PrintHeader = True
    for Item in FailedProvDbCheckLL:
      ItemNum += 1
      if (PrintHeader):
        PrintHeader = False
        print('')
        print('\nInstances Incorrectly Provisioned - Plan View (pg ' + str(PageNum) + ')')
        PageNum += 1
        print('----------------------------------------------------')
        print('')
        print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')
        print('    |                                                      | |                                                             |')
        print('###  Db Unique Name  Instance      Node            State       Db Unique Name    Instance        Node              State')
        print('---  --------------- ------------- --------------- --------    ----------------  --------------  ----------------  --------')

      ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,RegDbDbUniqueName,RegDbInstName, \
       RegDbNodeName,RegDbInstState = Item

      # Mark the mismatching attribute (rigistered side only)
      if (ProvDbDbUniqueName != RegDbDbUniqueName):
        RegDbDbUniqueName  = '~' + RegDbDbUniqueName
      else:
        RegDbDbUniqueName  = ' ' + RegDbDbUniqueName

      if (ProvDbInstName != RegDbInstName):
        RegDbInstName      = '~' + RegDbInstName
      else:
        RegDbInstName      = ' ' + RegDbInstName

      if (ProvDbNodeName     != RegDbNodeName):
        RegDbNodeName      = '~' + RegDbNodeName
      else:
        RegDbNodeName      = ' ' + RegDbNodeName

      if (ProvDbInstState    != RegDbInstState):
        RegDbInstState     = '~' + RegDbInstState
      else:
        RegDbInstState     = ' ' + RegDbInstState

      print('%3s  %-15s %-13s %-15s %-8s   %-16s  %-14s  %-16s  %-9s' % (ItemNum,ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName, \
       ProvDbInstState,RegDbDbUniqueName,RegDbInstName,RegDbNodeName,RegDbInstState))

      if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
        PrintHeader = True
        print('    |                                                      | |                                                             |')
        print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')

  if (not PrintHeader):
    print('    |                                                      | |                                                             |')
    print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')
  return
# End ReportFailedProvDbCheck()


# Def : ReportFailedParms()
# Desc: Prints a report showing the database parameters that do not conform 
#       to the provisioning plan.
# Args: FailedParmsDD
# Retn: 
#---------------------------------------------------------------------------
def ReportFailedParms(FailedParmsDD):
  PageSize = 50
  PageNum  = 1

  if (len(FailedParmsDD) == 0):
    print('\nNo improperly configured parameters found.')
  else:
    ItemNum = 0
    PrintHeader = True
    for DbUniqueName in sorted(FailedParmsDD.keys()):
      for Parameter in sorted(FailedParmsDD[DbUniqueName].keys()):
        ItemNum += 1
        if (PrintHeader):
          PrintHeader = False
          print('\n\nImproperly Configured Parameters (pg ' + str(PageNum) + ')')
          PageNum += 1
          print('----------------------------------------')
          print('')
          print('  Database         Parameter               Provisioned                Actual')
          print('  ---------------  ----------------------  -------------------------  -------------------------')
        print('  %-15s  %-22s  %25s  %25s' % (DbUniqueName, Parameter, splitThousands(FailedParmsDD[DbUniqueName][Parameter][0]), splitThousands(FailedParmsDD[DbUniqueName][Parameter][1])))

        if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
          PrintHeader = True
  return
# End ReportFailedParms()

# Def : ReportPassedParms()
# Desc: Prints a report showing the database parameters that conform to the  
#       provisioning plan.
# Args: PassedParmsDD
# Retn: 
#---------------------------------------------------------------------------
def ReportPassedParms(PassedParmsDD):
  PageSize = 50
  PageNum  = 1

  if (len(PassedParmsDD) == 0):
    print('\nEither no provisioned databases defined in improv.ini file')
    print('or no properly configured database parameters found.')
  else:
    ItemNum = 0
    PrintHeader = True
    for DbUniqueName in sorted(PassedParmsDD.keys()):
      for Parameter in sorted(PassedParmsDD[DbUniqueName].keys()):
        ItemNum += 1
        if (PrintHeader):
          PrintHeader = False
          print('\n\nProperly Configured Parameters (pg ' + str(PageNum) + ')')
          PageNum += 1
          print('--------------------------------------')
          print('')
          print('  Database         Parameter               Provisioned                Actual')
          print('  ---------------  ----------------------  -------------------------  -------------------------')
        print('  %-15s  %-22s  %25s  %25s' % (DbUniqueName, Parameter, splitThousands(PassedParmsDD[DbUniqueName][Parameter][0]), splitThousands(PassedParmsDD[DbUniqueName][Parameter][1])))

        if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
          PrintHeader = True
  return
# End ReportPassedParms()


# Def : ReportPassedRegDbCheck()
# Desc: Prints a report showing the databases in the cluster registry that
#       conform to the provisioning plan.
# Args: PassedRegDbCheckLL
# Retn: 
#---------------------------------------------------------------------------
def ReportPassedRegDbCheck(PassedRegDbCheckLL):
  PageSize = 50
  PageNum  = 1
  if (len(PassedRegDbCheckLL) == 0):
    print('\nEither no provisioned instances defined in improv.ini file')
    print('or no properly provisioned instances found.')
  else:
    ItemNum = 0
    PrintHeader = True
    for Item in PassedRegDbCheckLL:
      ItemNum += 1
      if (PrintHeader):
        PrintHeader = False
        print('\n\nInstances Properly Provisioned (pg ' + str(PageNum) + ')')
        PageNum += 1
        print('-------------------------------------')
        print('')
        print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')
        print('    |                                                      | |                                                             |')
        print('###  Db Unique Name  Instance      Node            State       Db Unique Name    Instance        Node              State')
        print('---  --------------- ------------- --------------- --------    ----------------  --------------  ----------------  --------')

      ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,RegDbDbUniqueName,RegDbInstName, \
       RegDbNodeName,RegDbInstState = Item

      print('%3s  %-15s %-13s %-15s %-8s    %-15s   %-13s   %-15s   %-8s' % (ItemNum,ProvDbDbUniqueName,ProvDbInstName, \
       ProvDbNodeName,ProvDbInstState,RegDbDbUniqueName,RegDbInstName,RegDbNodeName,RegDbInstState))

      if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
        PrintHeader = True
        print('    |                                                      | |                                                             |')
        print('    +-- Provisioned ---------------------------------------+ +--Registered ------------------------------------------------+')
  if (not PrintHeader):
    print('    |                                                      | |                                                             |')
    print('    +-- Provisioned ---------------------------------------+ +--Registered ------------------------------------------------+')
  return
# End: ReportPassedRegDbCheck()


# Def : ReportFailedRegDbCheck()
# Desc: Prints a report showing the databases in the cluster registry that
#       fail to conform to the provisioning plan.
# Args: FailedRegDbCheckLL
# Retn: 
#---------------------------------------------------------------------------
def ReportFailedRegDbCheck(FailedRegDbCheckLL):
  PageSize = 50
  PageNum  = 1

  if (len(FailedRegDbCheckLL) == 0):
    print('\n\nAll instances provisioned according to plan (Cluster Registry View)')
  else:
    ItemNum = 0
    PrintHeader = True
    for Item in FailedRegDbCheckLL:
      ItemNum += 1
      if (PrintHeader):
        PrintHeader = False
        print('')
        print('\nInstances Incorrectly Provisioned - Cluster Registry View (pg ' + str(PageNum) + ')')
        PageNum += 1
        print('----------------------------------------------------------------')
        print('')
        print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')
        print('    |                                                      | |                                                             |')
        print('###  Db Unique Name  Instance      Node            State       Db Unique Name    Instance        Node              State')
        print('---  --------------- ------------- --------------- --------    ----------------  --------------  ----------------  --------')

      ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,RegDbDbUniqueName,RegDbInstName, \
       RegDbNodeName,RegDbInstState = Item

      # Mark the mismatching attribute (rigistered side only)
      if (ProvDbDbUniqueName != RegDbDbUniqueName):
        RegDbDbUniqueName  = '~' + RegDbDbUniqueName
      else:
        RegDbDbUniqueName  = ' ' + RegDbDbUniqueName

      if (ProvDbInstName != RegDbInstName):
        RegDbInstName      = '~' + RegDbInstName
      else:
        RegDbInstName      = ' ' + RegDbInstName

      if (ProvDbNodeName     != RegDbNodeName):
        RegDbNodeName      = '~' + RegDbNodeName
      else:
        RegDbNodeName      = ' ' + RegDbNodeName

      if (ProvDbInstState    != RegDbInstState):
        RegDbInstState     = '~' + RegDbInstState
      else:
        RegDbInstState     = ' ' + RegDbInstState

      print('%3s  %-15s %-13s %-15s %-8s   %-16s  %-14s  %-16s  %-9s' % (ItemNum,ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName, \
       ProvDbInstState,RegDbDbUniqueName,RegDbInstName,RegDbNodeName,RegDbInstState))

      if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
        PrintHeader = True
        print('    |                                                      | |                                                             |')
        print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')

  if (not PrintHeader):
    print('    |                                                      | |                                                             |')
    print('    +-- Provisioned ---------------------------------------+ +-- Registered -----------------------------------------------+')
  return
# End: ReportFailedRegDbCheck()

# Def : ReportPassedProvSvcCheck()
# Desc: Prints a report showing the service names in the cluster registry 
#       that conform to the provisioning plan.
# Args: PassedProvSvcCheckLL
# Retn: 
#---------------------------------------------------------------------------
def ReportPassedProvSvcCheck(PassedProvSvcCheckLL):
  PageSize = 50
  PageNum  = 1

  if (len(PassedProvSvcCheckLL) == 0):
    print('\n\nEither no provisioned service names defined in improv.ini file')
    print('or no properly provisioned service names found.')
  else:
    ItemNum = 0
    PrintHeader = True
    for Item in PassedProvSvcCheckLL:
      ItemNum += 1
      if (PrintHeader):
        PrintHeader = False
        print('\n\nService Names Properly Provisioned (pg ' + str(PageNum) + ')')
        PageNum += 1
        print('-----------------------------------------                      +-- Provisioned --------------+ +-- Registered -------------+')
        print('                                                               |                             | |                           |')
        print('### Db Unique Name  Instance      Service                        Node              State         Node              State')
        print('--- --------------- ------------- ----------------------------   ----------------  ---------     ----------------  --------')

      ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,RegSvcDbUniqueName,RegSvcInstName, \
      RegSvcServiceName,RegSvcNodeName,RegSvcServiceState = Item

      print('%3s %-15s %-13s %-28s   %-15s   %-8s      %-15s   %-8s' % (ItemNum,ProvDbDbUniqueName,ProvDbInstName, \
       RegSvcServiceName,ProvDbNodeName,ProvDbInstState,RegSvcNodeName,RegSvcServiceState))

      if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
        PrintHeader = True
        print('                                                               |                             | |                           |')
        print('                                                               +-- Provisioned --------------+ +-- Registered -------------+')
  return
# End ReportPassedProvSvcCheck()

# Def : ReportFailedProvSvcCheck()
# Desc: Prints a report showing the service names in the cluster registry 
#       that fail to conform to the provisioning plan.
# Args: FailedProvSvcCheckLL
# Retn: 
#---------------------------------------------------------------------------
def ReportFailedProvSvcCheck(FailedProvSvcCheckLL):
  PageSize = 50
  PageNum  = 1

  if (len(FailedProvSvcCheckLL) == 0):
    print('\n\nAll service names provisioned according to plan.')
    print('------------------------------------------------')
  else:
    ItemNum = 0
    PrintHeader = True
    for Item in FailedProvSvcCheckLL:
      ItemNum += 1
      if (PrintHeader):
        PrintHeader = False
        print('\n\nService Names Incorrectly Provisioned (pg ' + str(PageNum) + ')')
        PageNum += 1
        print('--------------------------------------------                   +-- Provisioned --------------+ +-- Registered -------------+')
        print('                                                               |                             | |                           |')
        print('### Db Unique Name  Instance      Service                        Node              State         Node              State')
        print('--- --------------- ------------- ----------------------------   ----------------  ---------     ----------------  --------')

      ProvDbDbUniqueName,ProvDbInstName,ProvDbNodeName,ProvDbInstState,RegSvcDbUniqueName,RegSvcInstName, \
      RegSvcServiceName,RegSvcNodeName,RegSvcServiceState = Item

      # Mark the mismatching attribute (rigistered side only)
      if (ProvDbNodeName != RegSvcNodeName):
        RegSvcNodeName = '~' + RegSvcNodeName
      else:
        RegSvcNodeName = ' ' + RegSvcNodeName

      if (ProvDbInstState != RegSvcServiceState):
        RegSvcServiceState = '~' + RegSvcServiceState
      else:
        RegSvcServiceState = ' ' + RegSvcServiceState

      print('%3s %-15s %-13s %-28s   %-16s  %-9s    %-16s  %-9s' % (ItemNum,ProvDbDbUniqueName,ProvDbInstName, \
       RegSvcServiceName,ProvDbNodeName,ProvDbInstState,RegSvcNodeName,RegSvcServiceState))

      #print ItemNum % PageSize

      if (ItemNum % PageSize == 0):  # % is modulus (for pagination)
        PrintHeader   = True
        print('                                                               |                             | |                           |')
        print('                                                               +-- Provisioned --------------+ +-- Registered -------------+')

  if (not PrintHeader): # Print the footer before exiting.
    print('                                                               |                             | |                           |')
    print('                                                               +-- Provisioned --------------+ +-- Registered -------------+')
  return
# End: ReportFailedProvSvcCheck()

# Def : GenerateProvisioningCommands()
# Desc: Prints a the srvctl commands for registering the databases,
#       instances, and service names according to the provisioning plan.
# Args: ProvisionedDD, RegisteredNodeListOfDict
# Retn: 
#---------------------------------------------------------------------------
def GenerateProvisioningCommands(ProvisionedDD, RegisteredNodeListOfDict):
  NodeCount = len(RegisteredNodeListOfDict)

  print('\n--------------------------------------------------------------------------------------------------------------------------------------------------')
  print('-- Provisioning Commands -------------------------------------------------------------------------------------------------------------------------')
  print('--------------------------------------------------------------------------------------------------------------------------------------------------')
  FirstLoop = True
  for DbKey in sorted(ProvisionedDD.keys()):
    if (not FirstLoop):
      print('---                                                                                             ')
    db_unique_name         = ProvisionedDD[DbKey]['db_unique_name']
    db_name                = ProvisionedDD[DbKey]['db_name']
    user_name              = ProvisionedDD[DbKey]['user_name']
    password               = ProvisionedDD[DbKey]['password']
    host                   = ProvisionedDD[DbKey]['host']
    port                   = ProvisionedDD[DbKey]['port']
    service_name           = ProvisionedDD[DbKey]['service_name']
    password               = ProvisionedDD[DbKey]['password']
    pga_aggregate_target   = ProvisionedDD[DbKey]['pga_aggregate_target']
    db_cache_size          = ProvisionedDD[DbKey]['db_cache_size']
    shared_pool_size       = ProvisionedDD[DbKey]['shared_pool_size']
    streams_pool_size      = ProvisionedDD[DbKey]['streams_pool_size']
    large_pool_size        = ProvisionedDD[DbKey]['large_pool_size']
    java_pool_size         = ProvisionedDD[DbKey]['java_pool_size']
    sga_max_size           = ProvisionedDD[DbKey]['sga_max_size']
    sga_target             = ProvisionedDD[DbKey]['sga_target']
    memory_max_target      = ProvisionedDD[DbKey]['memory_max_target']
    memory_target          = ProvisionedDD[DbKey]['memory_target']
    total_storage          = ProvisionedDD[DbKey]['total_storage']
    datafile_bytes         = ProvisionedDD[DbKey]['datafile_bytes']
    tempfile_bytes         = ProvisionedDD[DbKey]['tempfile_bytes']
    controlfile_bytes      = ProvisionedDD[DbKey]['controlfile_bytes']
    redofile_bytes         = ProvisionedDD[DbKey]['redofile_bytes']

    # srvctl add database -d mvwprddal -n mvwprd -o /u01/app/oracle/product/11.2.0/dbhome_1 -p '+DATA/mvwprddal/spfilemvwprd.ora' -y automatic -a "DATA,RECO" -t immediate
    print('%19s %-2s %-10s %-2s %-10s %-15s %-10s %-40s' % ('srvctl add database','-d',db_unique_name,'-n',db_name,'-o $ORACLE_HOME',\
     '-p +DATA/' + db_unique_name + '/spfile' + db_name + '.ora', '-y automatic -a "DATA,RECO" -t immediate'))

    # Generate the add instance commands.
    InstId = 1
    for i in range(1,NodeCount+1):
      ProvNode = 'node' + str(i)
      NodeName = GetNodeName(str(i))
      if (upper(ProvisionedDD[DbKey][ProvNode]) in ['P','A','F']):
        InstName = db_name + str(InstId)
        print('%-19s %-2s %-10s %-2s %-10s %-2s %-12s' % ('srvctl add instance', '-d',db_unique_name,'-i',InstName,'-n',NodeName))
        InstId += 1    

    # Generate the add service commands.
    InstId = 1
    for SvcExt in ['AH','BP','OL','RP']:
      SvcName = upper(db_name) + SvcExt
      InstList = []
      for i in range(1,NodeCount+1):
        ProvNode = 'node' + str(i)
        NodeName = GetNodeName(str(i))
        if (upper(ProvisionedDD[DbKey][ProvNode]) in ['P','A','F']):
          InstName = db_name + str(InstId)
          InstList.append(InstName)
          InstId += 1    
      InstNames = join(InstList, ',')
      # srvctl add service   -d mvwprddal -s MVWPRDAH -r mvwprd1,mvwprd2 -P basic -e SELECT
      print('%-18s  %-2s %-10s %-2s %-10s %-2s %-40s %-19s' % ('srvctl add service','-d',db_unique_name,'-s',SvcName,'-r',InstNames,'-P basic -e SELECT'))
    FirstLoop = False
  print('--------------------------------------------------------------------------------------------------------------------------------------------------')
  print('-- End Provisioning Commands ---------------------------------------------------------------------------------------------------------------------')
  print('--------------------------------------------------------------------------------------------------------------------------------------------------')

  return
# End GenerateProvisioningCommands()

# Def : PrintRegisteredNodeListOfDict()
# Desc: Prints a dump of the RegisteredNodeListOfDict variable.
# Args: RegisteredNodeListOfDict
# Retn: 
#---------------------------------------------------------------------------
def PrintRegisteredNodeListOfDict(RegisteredNodeListOfDict):
  print('\n---------------------------------------------------')
  print('-- Registered Node List (olsnodes -n) -------------')
  print('---------------------------------------------------')
  print('  Node ID  Node Name')
  print('  -------  ---------------')
  for NodeDef in RegisteredNodeListOfDict:
    print('  %7s  %-15s ' % (NodeDef['NodeId'], NodeDef['NodeName']))
  print('---------------------------------------------------')
  print('-- End of Report: Registered Node List ------------')
  print('---------------------------------------------------\n')
  return
# End PrintRegisteredNodeListOfDict()


# Def : PrintRegisteredServerPoolDict()
# Desc: Prints a dump of the RegisteredServerPoolDict variable.
# Args: RegisteredServerPoolDict
# Retn: 
#---------------------------------------------------------------------------
def PrintRegisteredServerPoolDict(RegisteredServerPoolDict):
  print('\n-------------------------------------------------------------------------------------')
  print('-- Registered Server Pool Node Assignments (crsctl status serverpool) ---------------')
  print('-------------------------------------------------------------------------------------')
  print('  Server Pool Key                 Node List')
  print('  ------------------------------  ---------------------------------------------------')
  for PoolKey in sorted(RegisteredServerPoolDict.keys()):
    print('  %-30s  %-52s' % (PoolKey,RegisteredServerPoolDict[PoolKey]))
  print('-------------------------------------------------------------------------------------')
  print('-- End of Report: Registered Server Pool Assignments --------------------------------')
  print('-------------------------------------------------------------------------------------\n')
  return
# End PrintRegisteredServerPoolDict()


# Def : GetRunningDbInfo()
# Desc: Calls RunSqlplus() with queries to collect database information from
#       the running databases. 
# Args: ProvisionedDD
# Retn: RunningDbInfoDD
#---------------------------------------------------------------------------
def GetRunningDbInfo(ProvisionedDD):
  RunningDbInfoDD = {}
  SqlplusProcList = []

  for DbKey in sorted(ProvisionedDD.keys()):
    DbUniqueName  = ProvisionedDD[DbKey]['db_unique_name']
    Username      = ProvisionedDD[DbKey]['user_name']
    Password      = ProvisionedDD[DbKey]['password']
    Host          = ProvisionedDD[DbKey]['host']
    Port          = ProvisionedDD[DbKey]['port']
    ServiceName   = ProvisionedDD[DbKey]['service_name']
    ConnectString = Username + '/' + Password + '@' + Host + ':' + Port + '/' + ServiceName

    ParmsDict = {}
    ParmQry  = "set lines 2000"                                                + linesep
    ParmQry += "set pages 0"                                                   + linesep
    ParmQry += "col name  format a50"                                          + linesep
    ParmQry += "col value format a70"                                          + linesep
    ParmQry += "col bytes format 9999999999999999999999999999"                 + linesep
    ParmQry += "set feedback off"                                              + linesep
    ParmQry += "set echo off"                                                  + linesep
    ParmQry += "alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';"    + linesep
    ParmQry += "/* This query returns database instance parameters */"         + linesep
    ParmQry += "select '" + DbUniqueName + "' ||'~'||"                         + linesep
    ParmQry += "       i.ksppinm  ||'~'|| "                                    + linesep
    ParmQry += "       sv.ksppstvl"                                            + linesep
    ParmQry += "  from sys.x$ksppi  i,"                                        + linesep
    ParmQry += "       sys.x$ksppsv sv"                                        + linesep
    ParmQry += " where i.indx = sv.indx"                                       + linesep
    ParmQry += "   and i.ksppinm in ('db_name',"                               + linesep
    ParmQry += "                     'db_unique_name',"                        + linesep
    ParmQry += "                     'service_names',"                         + linesep
    ParmQry += "                     'db_domain',"                             + linesep
    ParmQry += "                     'db_cache_size',"                         + linesep
    ParmQry += "                     'cpu_count',"                             + linesep
    ParmQry += "                     'compatible',"                            + linesep
    ParmQry += "                     'resource_manager_plan',"                 + linesep
    ParmQry += "                     'streams_pool_size',"                     + linesep
    ParmQry += "                     'java_pool_size',"                        + linesep
    ParmQry += "                     'large_pool_size',"                       + linesep
    ParmQry += "                     'pga_aggregate_target',"                  + linesep
    ParmQry += "                     'statistics_level',"                      + linesep
    ParmQry += "                     'memory_target',"                         + linesep
    ParmQry += "                     'memory_max_target',"                     + linesep
    ParmQry += "                     'sga_max_size',"                          + linesep
    ParmQry += "                     'sga_target',"                            + linesep
    ParmQry += "                     'shared_pool_size',"                      + linesep
    ParmQry += "                     '_kill_diagnostics_timeout',"             + linesep
    ParmQry += "                     '_lm_rcvr_hang_allow_time',"              + linesep
    ParmQry += "                     'db_create_file_dest',"                   + linesep
    ParmQry += "                     'db_recovery_file_dest',"                 + linesep
    ParmQry += "                     'db_recovery_file_dest_size');"           + linesep

    # current_sga_size
    ParmQry += "select '" + DbUniqueName + "'||'~'||"
    ParmQry +=        "'current_sga_usage'||'~'||"
    ParmQry +=        "sum(value)"
    ParmQry +=  " from sys.v$sga;"                                             + linesep

    # Connected Instance
    ParmQry += "select '" + DbUniqueName + "'||'~'||"
    ParmQry +=        "'instance_name'||'~'||"
    ParmQry +=        "instance_name"
    ParmQry +=  " from sys.v$instance;"                                        + linesep

    # Database Version
    ParmQry += "select '" + DbUniqueName + "'||'~'||"
    ParmQry +=        "'db_version'||'~'||"
    ParmQry +=        "banner"                                                 + linesep
    ParmQry += "  from sys.v$version"                                          + linesep
    ParmQry += " where banner like 'Oracle Database %';"                       + linesep

    # Storage for data files
    ParmQry += "select '" + DbUniqueName + "'||'~'||"
    ParmQry +=        "'datafile_bytes'||'~'||"
    ParmQry +=         "sum(bytes)"
    ParmQry +=  " from dba_data_files;"                                        + linesep

    # Storage for temp files
    ParmQry += "select '" + DbUniqueName + "'||'~'||"
    ParmQry +=        "'tempfile_bytes'||'~'||"
    ParmQry +=         "sum(bytes)"
    ParmQry +=  " from dba_temp_files;"                                        + linesep

    # Storage for redo logs
    ParmQry += "select '" + DbUniqueName + "'||'~'||"
    ParmQry +=        "'redofile_bytes'||'~'||"
    ParmQry +=         "sum(bytes)"
    ParmQry +=  " from v$log;"                                                 + linesep

    # Storage for controlfiles
    ParmQry += "select '" + DbUniqueName + "'||'~'||"
    ParmQry +=        "'controlfile_bytes'||'~'|| "
    ParmQry +=         "sum(block_size*file_size_blks)"
    ParmQry +=  " from v$controlfile;"                                         + linesep

    # Total storage (datafiles + tempfiles + redo logs + controlfiles)
    ParmQry += "select '" + DbUniqueName + "' ||'~total_storage~'|| "          + linesep
    ParmQry += "        (dfiles.bytes + tfiles.bytes + "
    ParmQry +=         "rfiles.bytes + cfiles.bytes)"                          + linesep
    ParmQry += "  FROM (select 'a' col1, sum(bytes) bytes"
    ParmQry +=         " FROM dba_data_files)                     dfiles,"     + linesep
    ParmQry += "       (SELECT 'a' col1, sum(bytes) bytes"
    ParmQry +=         " FROM dba_temp_files)                     tfiles,"     + linesep
    ParmQry += "       (SELECT 'a' col1, sum(bytes) bytes"
    ParmQry +=         " FROM v$log)                              rfiles,"     + linesep
    ParmQry += "       (SELECT 'a' col1, "
    ParmQry +=        "sum(block_size*file_size_blks) bytes"
    ParmQry +=         " FROM v$controlfile)  cfiles"                          + linesep
    ParmQry += " WHERE dfiles.col1 = tfiles.col1"                              + linesep
    ParmQry += "   AND dfiles.col1 = rfiles.col1"                              + linesep
    ParmQry += "   AND dfiles.col1 = cfiles.col1;"                             + linesep
    ParmQry += "EXIT"                                                          + linesep

    # Fetch parameters from the database
    print('\r                                                                  ', end=' ')
    print('\r Spawning background extract for:', DbUniqueName, end=' ')
    stdout.flush()

    try:
      if (Username.upper() == 'SYS'):
        proc = Popen([Sqlplus, '-s', ConnectString, 'AS', 'SYSDBA'], stdin=PIPE, stdout=PIPE, stderr=STDOUT, \
         shell=False, universal_newlines=True, close_fds=True)
      else:
        proc = Popen([Sqlplus, '-s', ConnectString], stdin=PIPE, stdout=PIPE, stderr=STDOUT, \
         shell=False, universal_newlines=True, close_fds=True)
      # Run the query
      proc.stdin.write(ParmQry)
      SqlplusProcList.append((DbUniqueName,proc))
    except:
      formatExceptionInfo()
      print('Failed to connect to database: ' + DbUniqueName + ' (database may be shutdown)')
      print('  Database may be offline. Connect string follows : ' + ConnectString)
      print('  This database will be skipped...')

  for Connection in SqlplusProcList:
    (DbUniqueName, proc) = Connection
    print('\r                                                               ', end=' ')
    print('\r Waiting for extract to complete for:', DbUniqueName, end=' ')
    stdout.flush()
    proc.wait()
  # Clear the line and reset to beginning of next line for next print.
  print('\r                                                    ', end=' ')
  print('\r', end=' ')

  for Connection in SqlplusProcList:
    (DbUniqueName, proc) = Connection
    SqlOut = proc.stdout.read()                 # store the output in string format
    SqlOut = SqlOut.rstrip()                    # remove any trailing white spaces

    # Check for sqlplus errors
    (rc, ErrorStack) = ErrorCheck(SqlOut)
    if (rc != 0):
      PrintError(ErrorStack)
      print(' Error Probing ' + DbUniqueName + '. This database will be skipped.\n')
    else:
      ParmsDict = {}
      for line in SqlOut.split('\n'):
        (DbUniqueName, Parm, Value) = line.split('~')
        ParmsDict[Parm] = Value
        if len(list(ParmsDict.keys())) >= 1:
          RunningDbInfoDD[DbUniqueName] = ParmsDict
  return(RunningDbInfoDD)
# End GetRunningDbInfo()


# Def : GetCrsctlServerPoolOutput()
# Desc: Calls crsctl status serverpool command and returns the stdout to
#       the calling routine.
# Args: 
# Retn: Crsctl_SrvPool_Stdout
#---------------------------------------------------------------------------
def GetCrsctlServerPoolOutput():
  Crsctl_SrvPool_Proc   = Popen([CrsCtl, 'status', 'serverpool'], bufsize=1, stdin=PIPE, stdout=PIPE, stderr=STDOUT, shell=False, universal_newlines=True, close_fds=True)
  Crsctl_SrvPool_Stdout = Crsctl_SrvPool_Proc.stdout.read()   # store the output in string format
  Crsctl_SrvPool_Stdout = Crsctl_SrvPool_Stdout.rstrip()      # remove any trailing white spaces

  return(Crsctl_SrvPool_Stdout)
# End GetCrsctlServerPoolOutput()

# Def : GetAllServerPools()
# Desc: Parses the output from the crsctl status serverpool command (
#       GetCrsctlServerPoolOutput()) and builds a list of all server pools
#       in the cluster.
# Args: Crsctl_SrvPool_Stdout
# Retn: RegisteredServerPoolDict
#---------------------------------------------------------------------------
def GetAllServerPools(Crsctl_SrvPool_Stdout):
  RegisteredServerPoolDict = {}

  # The following command returns a listing similar to...
  # NAME=ora.fssit_FSSITAH
  # ACTIVE_SERVERS=td01db03 td01db04
  # --------------------------------------------------------
  ServerPoolList = Crsctl_SrvPool_Stdout.split('\n\n')

  for ServerPool in ServerPoolList:
    NameLine, ServerLine = ServerPool.split('\n')
    NameLabel, Name      = NameLine.split('=')
    ServerLabel, Servers = ServerLine.split('=')
    ServerList = Servers.split(' ')
    RegisteredServerPoolDict[Name] = ServerList
  return(RegisteredServerPoolDict)
# End GetAllServerPools


# Def : GetServiceDetails()
# Desc: Runs the srvctl config service -d {DbUniqueName} -s {ServiceName}
#       command for each database/service name and creates two structures
#       that store the parsed output, and the aparent provisioning scheme. 
#       This output shows the Preferred/Available configuration for service
#       names as configured in the cluster.
# Args: RegSvcProvSchemeDD, RegisteredDbDD
# Retn: RegSvcDetailDD, RegSvcDetailProvSchemeDD
#---------------------------------------------------------------------------
def GetServiceDetails(RegSvcProvSchemeDD, RegisteredDbDD):
  OldOracleHome               = environ['ORACLE_HOME']
  RegServiceDetailDict        = {}
  RegSvcDetailDD              = {}
  SvcKeyList                  = sorted(RegSvcProvSchemeDD.keys())
  ServiceCount                = len(list(RegSvcProvSchemeDD.keys()))
  Srvctl_CfgService_Procs     = []

  AqHaNotifications           = ''
  AvailableInstances          = ''
  AvailableInstanceList       = []
  Cardinality                 = ''
  ConnectionLoadBalancingGoal = ''
  DefaultServiceState         = ''
  DisabledInstanceList        = []
  Disconnect                  = ''
  DtpTransaction              = ''
  Edition                     = ''
  EnabledInstanceList         = []
  FailoverMethod              = ''
  FailoverType                = ''
  ManagementPolicy            = ''
  PreferredInstances          = ''
  PreferredInstanceList       = []
  RuntimeLoadBalancingGoal    = ''
  ServerPool                  = ''
  ServiceRole                 = ''
  TafFailoverDelay            = ''
  TafFailoverRetries          = ''
  TafPolicySpecification      = ''

  Count = 0
  pctComplete = 0.00
  SvcKeyIndex = 0
  for SvcKey in SvcKeyList:
    DbUniqueName, ServiceName = SvcKey.split('~')
    Count += 1
    pctComplete = ((1.0*Count) / ServiceCount) * 100
    print("\r  Percent Complete: %.0f" % pctComplete, " ", end=' ')
    stdout.flush()

    # Need to use the srvctl command from the database home.
    OracleHome = RegisteredDbDD['ora.'+DbUniqueName+'.db']['OracleHome']
    environ['ORACLE_HOME']  = OracleHome
    Srvctl = OracleHome +'/bin/srvctl'
    proc = Popen([Srvctl, 'config', 'service', '-d', DbUniqueName, '-s', ServiceName], stdin=PIPE, stdout=PIPE, stderr=STDOUT, shell=False, universal_newlines=True, close_fds=True)
    Srvctl_CfgService_Procs.append(proc)

  print("\r  Waiting for all child processes to complete.")
  for proc in Srvctl_CfgService_Procs:
    proc.wait()

  SvcKeyIndex = 0
  for proc in Srvctl_CfgService_Procs:
    procStdout = proc.stdout.read()                 # store the output in string format
    procStdout = procStdout.rstrip()                # remove any trailing white spaces
    RegServiceDetailList = procStdout.split('\n')

    # print procStdout
    # print '----------------'
    # Need to add error checking for stuff like this...
    # ---------------------------------------------------
    # PRCD-1027 : Failed to retrieve database hcmtrg
    # PRCD-1229 : An attempt to access configuration of database hcmtrg was rejected because its version 11.2.0.2.0 differs from the program version 11.2.0.3.0. Inst                                  ead run the program from /u01/app/oracle/product/11.2.0/dbhome_1.

    for Attribute in RegServiceDetailList:
      pos = Attribute.find('Service name:', 0, 13)
      if (pos >= 0):
        ServiceName = Attribute[13:].strip()

      # Service Enabled line
      pos = Attribute.find('Service is enabled', 0, 18)
      if (pos >= 0):
        # Check whether or not this is the default state
        pos2 = Attribute.find('Service is enabled on instances: ', 0, 33)
        if (pos2 >= 0):
          # Not the default state... this is an instance override.
          try:
            EnabledInstaneList = Attribute[33:].split(',')
          except:
            EnabledInstanceList = Attribute[33:]
        else:
          # This is the default state of the service name
          DefaultServiceState = 'enabled'

      # Service Enabled line
      pos = Attribute.find('Service is disabled', 0, 19)
      if (pos >= 0):
        # Check whether or not this is the default state
        pos2 = Attribute.find('Service is disabled on instances: ', 0, 34)
        if (pos2 >= 0):
          # Not the default state... this is an instance override.
          try:
            DisabledInstanceList = Attribute[34:].split(',')
          except:
            DisabledInstanceList = Attribute[34:]
        else:
          # This is the default state of the service name
          DefaultServiceState = 'disabled'

      # Server pool: padev_padevRP
      pos = Attribute.find('Server pool:', 0, 12)
      if (pos >= 0):
        ServerPool = Attribute[12:].strip()

      # Cardinality: 2
      pos = Attribute.find('Cardinality:', 0, 12)
      if (pos >= 0):
        Cardinality = Attribute[12:].strip()

      # Disconnect: false
      pos = Attribute.find('Disconnect:', 0, 11)
      if (pos >= 0):
        Disconnect = Attribute[11:].strip()

      # Service role: PRIMARY
      pos = Attribute.find('Service role:', 0, 13)
      if (pos >= 0):
        ServiceRole = Attribute[13:].strip()

      # Management policy: AUTOMATIC
      pos = Attribute.find('Management policy:', 0, 18)
      if (pos >= 0):
        ManagementPolicy = Attribute[18:].strip()

      # DTP transaction: false
      pos = Attribute.find('DTP transaction:', 0, 16)
      if (pos >= 0):
        DtpTransaction = Attribute[16:].strip()

      # AQ HA notifications: false
      pos = Attribute.find('AQ HA notifications:', 0, 20)
      if (pos >= 0):
        AqHaNotifications = Attribute[20:].strip()

      # Failover type: SELECT
      pos = Attribute.find('Failover type:', 0, 14)
      if (pos >= 0):
        FailoverType = Attribute[14:].strip()

      # Failover method: NONE
      pos = Attribute.find('Failover method:', 0, 16)
      if (pos >= 0):
        FailoverMethod = Attribute[16:].strip()

      # TAF failover retries: 0
      pos = Attribute.find('TAF failover retries:', 0, 21)
      if (pos >= 0):
        TafFailoverRetries = Attribute[21:].strip()

      # TAF failover delay: 0
      pos = Attribute.find('TAF failover delay:', 0, 19)
      if (pos >= 0):
        TafFailoverDelay = Attribute[19:].strip()

      # Connection Load Balancing Goal: LONG
      pos = Attribute.find('Connection Load Balancing Goal:', 0, 31)
      if (pos >= 0):
        ConnectionLoadBalancingGoal = Attribute[31:].strip()

      # Runtime Load Balancing Goal: NONE
      pos = Attribute.find('Runtime Load Balancing Goal:', 0, 29)
      if (pos >= 0):
        RuntimeLoadBalancingGoal = Attribute[29:].strip()

      # TAF policy specification: BASIC
      pos = Attribute.find('TAF policy specification:', 0, 25)
      if (pos >= 0):
        TafPolicySpecification = Attribute[25:].strip()

      # Edition:
      pos = Attribute.find('Edition:', 0, 8)
      if (pos >= 0):
        Edition = Attribute[8:].strip()

      # Preferred instances: padev1,padev2
      pos = Attribute.find('Preferred instances:', 0, 20)
      if (pos >= 0):
        PreferredInstances = Attribute[20:].strip()
        try:
          PreferredInstanceList = PreferredInstances.split(',')
        except:
          PreferredInstanceList = [PreferredInstances]

      # Available instances:
      pos = Attribute.find('Available instances:', 0, 20)
      if (pos >= 0):
        AvailableInstances = Attribute[20:].strip()
        try:
          AvailableInstanceList = AvailableInstances.split(',')
        except:
          AvailableInstanceList = [AvailableInstances]

    RegServiceDetailDict = {
      'ServiceKey'                  : SvcKey,
      'AqHaNotifications'           : AqHaNotifications,
      'AvailableInstances'          : AvailableInstances,
      'AvailableInstanceList'       : AvailableInstanceList,
      'Cardinality'                 : Cardinality,
      'ConnectionLoadBalancingGoal' : ConnectionLoadBalancingGoal,
      'DefaultServiceState'         : DefaultServiceState,
      'DisabledInstanceList'        : DisabledInstanceList,
      'Disconnect'                  : Disconnect,
      'DtpTransaction'              : DtpTransaction,
      'Edition'                     : Edition,
      'EnabledInstanceList'         : EnabledInstanceList,
      'FailoverMethod'              : FailoverMethod,
      'FailoverType'                : FailoverType,
      'ManagementPolicy'            : ManagementPolicy,
      'ServiceName'                 : ServiceName,
      'PreferredInstances'          : PreferredInstances,
      'PreferredInstanceList'       : PreferredInstanceList,
      'RuntimeLoadBalancingGoal'    : RuntimeLoadBalancingGoal,
      'ServerPool'                  : ServerPool,
      'ServiceRole'                 : ServiceRole,
      'TafFailoverDelay'            : TafFailoverDelay,
      'TafFailoverRetries'          : TafFailoverRetries,
      'TafPolicySpecification'      : TafPolicySpecification
    }

    RegSvcDetailDD[SvcKeyList[SvcKeyIndex]] = RegServiceDetailDict
    SvcKeyIndex += 1

  # Create a provisioned structure
  RegSvcDetailProvSchemeDD = {}
  for SvcKey in sorted(RegSvcDetailDD.keys()):
    DbUniqueName          = SvcKey.split('~')[0]
    ServiceName           = RegSvcDetailDD[SvcKey]['ServiceName']
    DefaultServiceState   = RegSvcDetailDD[SvcKey]['DefaultServiceState']
    DisabledInstanceList  = RegSvcDetailDD[SvcKey]['DisabledInstanceList']
    EnabledInstanceList   = RegSvcDetailDD[SvcKey]['EnabledInstanceList']
    PreferredInstanceList = RegSvcDetailDD[SvcKey]['PreferredInstanceList']
    AvailableInstanceList = RegSvcDetailDD[SvcKey]['AvailableInstanceList']

    ###~ This is what I've got...
    ###~ RegSvcProvSchemeDD[pauat~PAUATAH]{
    ###~   'node1': '' ,
    ###~   'node2': 'pauat,pauat1,PAUATAH,td01db02,enabled',
    ###~   'node3': 'pauat,pauat2,PAUATAH,td01db03,enabled',
    ###~   'node4': '',
    ###~   'node5': '',
    ###~   'node6': '',
    ###~   'node7': '',
    ###~   'node8': ''
    ###~ }

    ###~ ...and this is what I need to create
    ###~ RegSvcDetailProvSchemeDD[pauat~PAUATAH]{
    ###~   'node1': '' ,
    ###~   'node2': 'pauat,pauat1,PAUATAH,td01db02,enabled,Preferred',
    ###~   'node3': 'pauat,pauat2,PAUATAH,td01db03,enabled,Available',
    ###~   'node4': '',
    ###~   'node5': '',
    ###~   'node6': '',
    ###~   'node7': '',
    ###~   'node8': ''
    ###~ }

    NodeState = ''
    ProvNode  = ''

    RegSvcDetailProvSchemeDD[DbUniqueName + '~' + ServiceName] = {
      'node1' : '',
      'node2' : '',
      'node3' : '',
      'node4' : '',
      'node5' : '',
      'node6' : '',
      'node7' : '',
      'node8' : ''
    }

    for ProvKey in RegSvcProvSchemeDD:
      if (ProvKey == SvcKey):
        for ProvNode in sorted(RegSvcProvSchemeDD[ProvKey].keys()):
          if (RegSvcProvSchemeDD[ProvKey][ProvNode] == ''):
            RegSvcDetailProvSchemeDD[SvcKey][ProvNode] = ''
          else:
            ProvInst  = RegSvcProvSchemeDD[ProvKey][ProvNode].split(',')[1]
            ProvState = RegSvcProvSchemeDD[ProvKey][ProvNode].split(',')[4]
            if (ProvInst in PreferredInstanceList):
              ProvFlag = 'Preferred'
            else:
              if (ProvInst in AvailableInstanceList):
                ProvFlag = 'Available'
            RegSvcDetailProvSchemeDD[SvcKey][ProvNode] = RegSvcProvSchemeDD[ProvKey][ProvNode] + ',' + ProvFlag

  # Reset the ORACLE_HOME to what it was when this function was called.
  environ['ORACLE_HOME'] = OldOracleHome
  
  return(RegSvcDetailDD, RegSvcDetailProvSchemeDD)
# End GetServiceDetails()


# Def : PrintRegDbProvSchemeDD()
# Desc: Prints a dump of the RegDbProvSchemeDD variable.
# Args: RegDbProvSchemeDD
# Retn: 
#---------------------------------------------------------------------------
def PrintRegDbProvSchemeDD(RegDbProvSchemeDD):
  print('\n-----------------------------------------------------------------------------------------')
  print('-- Database/Instance Provisioning Schemes From OCR --------------------------------------')
  print('-----------------------------------------------------------------------------------------')
  FirstLoop = True
  print('  Database         Instance         Node          State')
  print('  ---------------  ---------------  ------------  ------------')
  for DbKey in sorted(RegDbProvSchemeDD):
    if (not FirstLoop):
      print('  ---')
    for i in range(1,8):
      ProvKey = 'node' + str(i)
      if RegDbProvSchemeDD[DbKey][ProvKey] != '':
        (db, inst, node, state) = split(RegDbProvSchemeDD[DbKey][ProvKey], ',')
        print('  %-15s  %-15s  %-12s  %-8s' % (db,inst,node,state))
    FirstLoop = False
  print('-----------------------------------------------------------------------------------------')
  print('-- End of Report: Database/Instance Provisioning Schemes --------------------------------')
  print('-----------------------------------------------------------------------------------------\n')

  return
# End PrintRegDbProvSchemeDD()


# Def : PrintRegSvcProvSchemeDD()
# Desc: Prints a dump of the RegSvcProvSchemeDD variable.
# Args: RegSvcProvSchemeDD
# Retn: 
#---------------------------------------------------------------------------
def PrintRegSvcProvSchemeDD(RegSvcProvSchemeDD):
  print('\n------------------------------------------------------------------------------------------')
  print('-- Service Name Provisioning Status (from OCR) -------------------------------------------')
  print('------------------------------------------------------------------------------------------')
  FirstLoop = True
  print('  Database         Instance         Service Name                    Node        State')
  print('  ---------------  ---------------  ------------------------------  ----------  --------')

  for SvcKey in sorted(RegSvcProvSchemeDD):
    if (not FirstLoop):
      print('  ---')
    for i in range(1,8):
      ProvKey = 'node' + str(i)
      if RegSvcProvSchemeDD[SvcKey][ProvKey] != '':
        (db, inst, svc, node, state) = split(RegSvcProvSchemeDD[SvcKey][ProvKey], ',')
        print('  %-15s  %-15s  %-30s  %-10s  %-8s' % (db,inst,svc,node,state))
    FirstLoop = False
  print('------------------------------------------------------------------------------------------')
  print('-- End of Report: Service Name Provisioning Status ---------------------------------------')
  print('------------------------------------------------------------------------------------------\n')

  return
# End PrintRegSvcProvSchemeDD()


# Def : GetInstanceName()
# Desc: Takes a {servicename}={nodename} pair and return the instance name.
# Args: ServiceNodeName, GenUsrOraInstNameServernameList
# Retn: Instance name -or- '0' for not found.
#---------------------------------------------------------------------------
def GetInstanceName(ServiceNodeName, GenUsrOraInstNameServernameList):
  for cell in GenUsrOraInstNameServernameList:
    DbNodeName, InstName = cell.split('=')
    if (ServiceNodeName == DbNodeName):
      return(InstName)
  return('0')
# End GetInstanceName()


# Def : GetInstanceNode()
# Desc: Takes an instance name and returns the name of the node on which it
#       is registered.
# Args: InstName, GenUsrOraInstNameServernameList
# Retn: Node name -or- '0' for not found.
#---------------------------------------------------------------------------
def GetInstanceNode(InstName, GenUsrOraInstNameServernameList):
  for cell in GenUsrOraInstNameServernameList:
    DbNodeName, DbInstName = cell.split('=')
    if (InstName == DbInstName):
      return(DbNodeName)
  return('0')
# End GetInstanceNode()


# Def : PrintProvSchemeDD()
# Desc: Prints a dump of the ProvSchemeDD variable.
# Args: ProvSchemeDD
# Retn: 
#---------------------------------------------------------------------------
def PrintProvSchemeDD(ProvSchemeDD):
  print('\n------------------------------------------------------------------')
  print('-- Provisioning Schemes From improv.ini --------------------------')
  print('------------------------------------------------------------------')
  FirstLoop = True
  print('  Database         Instance         Node          State     Flag')
  print('  ---------------  ---------------  ------------  --------  ----')
  for DbKey in sorted(ProvSchemeDD.keys()):
    if (not FirstLoop):
      print('  ---                                                                                             ')
    for i in range(1,8):
      ProvKey = 'node' + str(i)
      if ProvSchemeDD[DbKey][ProvKey] != '':
        (db, inst, node, state, flag) = split(ProvSchemeDD[DbKey][ProvKey], ',')
        print('  %-15s  %-15s  %-12s  %-8s  %-1s' % (db,inst,node,state,flag))
    FirstLoop = False
  print('------------------------------------------------------------------')
  print('-- End of Report: Provisioning Schemes ---------------------------')
  print('------------------------------------------------------------------\n')
  
  return
# End PrintProvSchemeDD()


# Def : PrintProvSchemeReport()
# Desc: Prints a report of the provisioning plan as read from the improv.ini
#       file.
# Args: ProvSchemeDD, RegisteredNodeListOfDict
# Retn: 
#---------------------------------------------------------------------------
def PrintProvSchemeReport(ProvSchemeDD, RegisteredNodeListOfDict):
  ProvSchemeDict = {}
  ProvSchemeDDD  = {}
  TmpDD          = {}
  NodeList       = []

  # Convert the list in ProvSchemeDD into a dict structure.
  # This is just to make it easier to traverse for this report.
  for ProvKey in sorted(ProvSchemeDD.keys()):
    for ProvNode in sorted(ProvSchemeDD[ProvKey].keys()):
      if (ProvSchemeDD[ProvKey][ProvNode] != ''):
        ProvSchemeDict = {
          'DbUniqueName' : ProvSchemeDD[ProvKey][ProvNode].split(',')[0],
          'InstName'     : ProvSchemeDD[ProvKey][ProvNode].split(',')[1],
          'NodeName'     : ProvSchemeDD[ProvKey][ProvNode].split(',')[2],
          'InstState'    : ProvSchemeDD[ProvKey][ProvNode].split(',')[3],
          'ProvFlag'     : ProvSchemeDD[ProvKey][ProvNode].split(',')[4]
        }
        TmpDD[ProvNode] = ProvSchemeDict
    ProvSchemeDDD[ProvKey] = TmpDD
    TmpDD = {}

  NodeCount = len(RegisteredNodeListOfDict)
  for Node in RegisteredNodeListOfDict:
    NodeList.append(Node['NodeName'])

  NodeList.sort()
  FirstNode = NodeList[0]
  LastNode  = NodeList[-1]

  # Print report headers
  print('')
  print('Database Provisioning Plan - Compute Nodes ' + FirstNode + '..' + LastNode)
  print('---------------------------------------------------------------\n')
  print('Db Unique Name', end=' ')
  for Node in RegisteredNodeListOfDict:
    print('   ' + Node['NodeId'], end=' ')

  print('\n---------------', end=' ')
  for Node in RegisteredNodeListOfDict:
    print(' ---', end=' ')

  # Report body
  for ProvKey in sorted(ProvSchemeDDD.keys()):
    print('\n%-17s' % (ProvKey), end=' ')
    for i in range(1, NodeCount + 1):
      ProvNode = 'node' + str(i)
      if (ProvNode in list(ProvSchemeDDD[ProvKey].keys())):
        print('%-4s' % (ProvSchemeDDD[ProvKey][ProvNode]['ProvFlag']), end=' ')
      else:
        print('    ', end=' ')
  
  return
# End PrintProvSchemeReport()


# Def : PrintOptions()
# Desc: Prints the command line options specified.
# Args: 
# Retn: 
#---------------------------------------------------------------------------
def PrintOptions():
  print('\n-----------------------------------------')
  print('-- Command Line Options -----------------')
  print('-----------------------------------------')
  print('  GenCommands    = ', options.GenCommands)
  print('  ImportPlan     = ', options.ImportPlan)
  print('  ExportPlan     = ', options.ExportPlan)
  print('  ProbeDbs       = ', options.ProbeDbs)
  print('  Replay         = ', options.Replay)
  print('  ServiceDetlRpt = ', options.ServiceDetlRpt)
  print('  StrictMatch    = ', options.StrictMatch)
  print('  Verbose        = ', options.Verbose)
  print('  TraceLevel     = ', options.TraceLevel)
  print('-----------------------------------------')
  print('-- End of Report: Command Line Options --')
  print('-----------------------------------------\n')
# End PrintOptions()


# Def : PrintRegSvcDetailDD()
# Desc: Prints a dump of the RegServiceDetailDD variable.
# Args: RegServiceDetailDD
# Retn: 
#---------------------------------------------------------------------------
def PrintRegSvcDetailDD(RegServiceDetailDD):
  print('\n---------------------------------------------------------------------------------------------------')
  print('-- Registered Service Name Detail from OCR --------------------------------------------------------')
  print('---------------------------------------------------------------------------------------------------')
  FirstLoop = True
  print('  Service Key                Attribute                       Value')
  print('  -------------------------  ------------------------------  --------------------------------------')
  for SvcKey in sorted(RegServiceDetailDD.keys()):
    if (not FirstLoop):
      print('  ---                                                                                              ')
    for SvcKey2 in sorted(RegServiceDetailDD[SvcKey].keys()):
      #print RegServiceDetailDD[SvcKey][SvcKey2]
      #print SvcKey, ' --> ', SvcKey2, ' ', RegServiceDetailDD[SvcKey][SvcKey2]
      print('  %-25s  %-30s = %-38s' % (SvcKey, SvcKey2, RegServiceDetailDD[SvcKey][SvcKey2]))
    FirstLoop = False
  print('---------------------------------------------------------------------------------------------------')
  print('-- End of Report: Registered Service Name Detail --------------------------------------------------')
  print('---------------------------------------------------------------------------------------------------\n')
  return
# End PrintRegSvcDetailDD

# Def : ReportRegSvcDetailProvSchemeDD()
# Desc: Prints a dump of the RegServiceDetailDD variable.
# Args: RegServiceDetailDD
# Retn: 
#---------------------------------------------------------------------------
def ReportRegSvcDetailProvSchemeDD(RegSvcDetailProvSchemeDD):
  prevdb = ''

  print('Detail Service Name Provisioning Status (from OCR)')
  print('--------------------------------------------------\n')
  FirstLoop = True
  print('  Database         Service          Instance         Node          State     Connections')
  print('  ---------------  ---------------  ---------------  ------------  --------  -----------')
  for SvcKey in sorted(RegSvcDetailProvSchemeDD):
    for i in range(1,8):
      ProvKey = 'node' + str(i)
      if RegSvcDetailProvSchemeDD[SvcKey][ProvKey] != '':
        (db, svc, inst, node, state, flag) = split(RegSvcDetailProvSchemeDD[SvcKey][ProvKey], ',')
        if (db != prevdb and FirstLoop == False):
          print('  ---')
        prevdb = db
        FirstLoop = False
        print('  %-15s  %-15s  %-15s  %-12s  %-8s  %1s' % (db,inst,svc,node,state,flag))
      FirstLoop = False
  print('-----------------------------------------------------------------------------------------')
  print('-- End of Report: Detail Service Name Provisioning Status -------------------------------')
  print('-----------------------------------------------------------------------------------------')
# End PrintRegSvcProvSchemeDD()


# Def : GetRegDbAttr(RegisteredDD, RegKey, Attribute)
# Desc: Takes a registered DD variable (RegisteredSvcDD, RegisteredDbDD)
#       variable, a registration key, and an attribute, and returns the
#       attributes value.
# Args: RegisteredDD, RegKey, Attribute
# Retn: 
#---------------------------------------------------------------------------
def GetRegDbAttr(RegisteredDD, RegKey, Attribute):
  return(RegisteredDD[RegKey][Attribute])
# End GetRegDbAttr()

# Def : splitThousands()
# Desc: Simple function to format numbers with commas to separate thousands.
# Args: s    = numeric_string
#       tSep = thousands_separation_character (default is ',')
#       dSep = decimal_separation_character (default is '.')
# Retn: formatted string
#---------------------------------------------------------------------------
def splitThousands( s, tSep=',', dSep='.'):
  '''Splits a general float on thousands. GIGO on general input'''
  if s == None:
    return(0)
  if not isinstance( s, str ):
    s = str( s )

  cnt=0
  numChars=dSep+'0123456789'
  ls=len(s)
  while cnt < ls and s[cnt] not in numChars: cnt += 1

  lhs = s[ 0:cnt ]
  s = s[ cnt: ]
  if dSep == '':
    cnt = -1
  else:
    cnt = s.rfind( dSep )
  if cnt > 0:
    rhs = dSep + s[ cnt+1: ]
    s = s[ :cnt ]
  else:
    rhs = ''

  splt=''
  while s != '':
    splt= s[ -3: ] + tSep + splt
    s = s[ :-3 ]

  return(lhs + splt[ :-1 ] + rhs)
# End splitThousands


# ==============================================================================
#  Main Program
# ==============================================================================
if (__name__ == '__main__'):
  Cmd        = basename(argv[0])
  CmdPrefix  = Cmd.split('.')[0]
  CmDDesc    = 'Improv'
  Version    = '1.1'
  AsmSid     = ''
  AsmHome    = ''
  AsmHome    = ''
  OratabFile = '/etc/oratab'
  Config     = SafeConfigParser()
  Now        = datetime.now()

  # Export/Import/Merge Filenames
  ImprovIni             = CmdPrefix + '.ini'
  ImpFilename           = CmdPrefix + '.csv'
  ExpFilename           = CmdPrefix + '-export.csv'
  MergeRunningFilename  = CmdPrefix + '-merge_running.ini'
  MergeImportedFilename = CmdPrefix + '-merge_imported.ini'

  # Pickle filenames (for serializing replay)
  pklRegisteredServerPoolData = CmdPrefix + '-' + 'RegisteredServerPoolData.pkl'   # serializes RegisteredServerPoolDict for replay (-r option)
  pklRegisteredNodeListData   = CmdPrefix + '-' + 'RegisteredNodeListData.pkl'     # serializes RegisteredNodeListOfDict for replay (-r option)
  pklRegDbProvSchemeData      = CmdPrefix + '-' + 'RegDbProvSchemeData.pkl'        # serializes RegDbProvSchemeDD        for replay (-r option)
  pklRegisteredDbData         = CmdPrefix + '-' + 'RegisteredDbData.pkl'           # serializes RegisteredDbDD           for replay (-r option)
  pklRegisteredSvcData        = CmdPrefix + '-' + 'RegisteredSvcData.pkl'          # serializes RegisteredSvcDD          for replay (-r option)
  pklRegSvcProvSchemeData     = CmdPrefix + '-' + 'RegSvcProvSchemeData.pkl'       # serializes RegSvcProvSchemeDD       for replay (-r option)
  pklSvcDetailData            = CmdPrefix + '-' + 'SvcDetailData.pkl'              # serializes RegSvcDetailDD           for replay (-r option)
  pklSvcDetailProvSchemeData  = CmdPrefix + '-' + 'SvcDetailProvSchemeData.pkl'    # serializes RegSvcDetailProvSchemeDD for replay (-r option)
  pklRunningDbInfoData        = CmdPrefix + '-' + 'RunningDbInfoData.pkl'          # serializes RunningDbInfoDD          for replay (-r option)

  # Process command line options
  # ----------------------------------
  ArgParser = OptionParser()
  ArgParser.add_option("-d", action="store_true",  dest="ServiceDetlRpt",    default=False,           help="generate a detailed report provisioned service names")
  ArgParser.add_option("-e", action="store_true",  dest="ExportPlan",        default=False,           help="export the provisioning plan to " + ExpFilename)
  ArgParser.add_option("-g", action="store_true",  dest="GenCommands",       default=False,           help="generate commands to provision database resources")
  ArgParser.add_option("-i", action="store_true",  dest="ImportPlan",        default=False,           help="import provisioning plan from " + ImpFilename)
  ArgParser.add_option("-p", action="store_true",  dest="ProbeDbs",          default=False,           help="probe Running databases for memory & config parameters")
  ArgParser.add_option("-r", action="store_true",  dest="Replay",            default=False,           help="replay the results of the last execution")
  ArgParser.add_option("-s", action="store_true",  dest="StrictMatch",       default=False,           help="strict compliance. Instance Number to Node must also match")
  ArgParser.add_option("-t",                       dest="TraceLevel",        default=0,     type=int, help="print runtime trace information. Levels include 0, 1, 2")
  ArgParser.add_option("-v", action="store_true",  dest="Verbose",           default=False,           help="report properly provisioned resources as well")

  options, args = ArgParser.parse_args()
  if (options.TraceLevel >= 1):
    PrintOptions()

  print('\n============================================================================================================================');
  print('Database Provisioning Utility for Oracle 11g                                    %44s' % (Now.strftime("%Y-%m-%d %H:%M")));
  print('============================================================================================================================');
  print('Program Info: %s v%s' % (Cmd, Version))
  print('')
  print('Options:')
  print('----------------------------------------------------   ----------------------------------------------------')
  print('(-i) Import Plan from %-22s : %-5s   (-d) Produce service detail report           : %-5s'                  % (ImpFilename, options.ImportPlan, options.ServiceDetlRpt))
  print('(-e) Export plan to %-24s : %-5s   (-s) Instance/Node names must match          : %-5s'                    % (ExpFilename, options.ExportPlan, options.StrictMatch))
  print('(-p) Probe databases for current parms       : %-5s   (-v) Verbose output                          : %-5s' % (options.ProbeDbs, options.Verbose))
  print('(-r) Replay previous collection              : %-5s   (-t) Trace output (levels 0,1,2)             : %-5s' % (options.Replay, options.TraceLevel))
  print('(-g) Generate provisioning commands          : %-5s'                                                       % (options.GenCommands))
  print('----------------------------------------------------   ----------------------------------------------------\n')
  
  # Setup the Oracle environment and set paths to the Oracle commands.
  # -------------------------------------------------------------------
  if not (options.Replay):
    (AsmHome) = SetOracleEnv('+ASM')
    if (AsmHome):
      OlsNodes = AsmHome + '/bin/olsnodes'
      Sqlplus  = AsmHome + '/bin/sqlplus'
      CrsCtl   = AsmHome + '/bin/crsctl'
    else:
      print('Error setting the ORACLE_HOME to the Grid Infrastructure (AsmHome)')
      exit(1)

  # Run 'crsctl status serverpool' and return it in a dictionary structure.
  # -------------------------------------------------------------------------
  print('Collecting server pools from OCR.')
  if (options.Replay):
    RegisteredServerPoolData = open(pklRegisteredServerPoolData,'rb')
    RegisteredServerPoolDict = pickle.load(RegisteredServerPoolData)
    RegisteredServerPoolData.close()
  else:
    #if (Crsctl_SrvPool_Stdout == ''):
    Crsctl_SrvPool_Stdout = GetCrsctlServerPoolOutput()
    RegisteredServerPoolDict = GetAllServerPools(Crsctl_SrvPool_Stdout)

  if (options.TraceLevel >= 1):
    PrintRegisteredServerPoolDict(RegisteredServerPoolDict)

  # Run 'olsnodes -n' and return it in a List of dictionaries structure.
  # This list contains all of the registered node names and their node id.
  # --------------------------------------------------------------------------
  print('Processing cluster node list from OCR.')
  if (options.Replay):
    RegisteredNodeListData = open(pklRegisteredNodeListData,'rb')
    RegisteredNodeListOfDict = pickle.load(RegisteredNodeListData)
    RegisteredNodeListData.close()
  else:
    #if (Olsnodes_Stdout == ''):
    Olsnodes_Stdout = GetOlsNodesOutput()
    RegisteredNodeListOfDict = GetRegisteredNodes(Olsnodes_Stdout)

  if (options.TraceLevel >= 1):
    PrintRegisteredNodeListOfDict(RegisteredNodeListOfDict)

  # Process the output from crsctl status resource -p and put it in a nested
  # dictionary structure.
  # The outer dictionary is structured as follows:
  #   dict[ResourceName]    For example: NAME=ora.fsprd.db
  # The inner dictionary is structured as follows:
  #   dict[AttributeName]   For example: DB_UNIQUE_NAME=bitrg
  # ----------------------------------------------------------------------------
  print('Processing database attributes in OCR.')
  if (options.Replay):
    RegDbProvSchemeData = open(pklRegDbProvSchemeData,'rb')
    RegDbProvSchemeDD = pickle.load(RegDbProvSchemeData)
    RegDbProvSchemeData.close()

    RegisteredDbData = open(pklRegisteredDbData,'rb')
    RegisteredDbDD = pickle.load(RegisteredDbData)
    RegisteredDbData.close()
  else:
    Crsctl_p_Stdout = GetCrsctlStatPOutput()
    RegisteredDbDD, RegDbProvSchemeDD = GetRegisteredDbAttributes(Crsctl_p_Stdout)

  if (options.TraceLevel >= 1):
    PrintRegDbProvSchemeDD(RegDbProvSchemeDD)
    if (options.TraceLevel >= 2):
      PrintRegisteredDbDD(RegisteredDbDD)

  # Process the output from crsctl status resource -p and put it in a nested
  # dictionary structure. The outer dictionary is structured as
  # follows:
  #   dict[ResourceName]       For example: NAME=ora.fsprdah.svc
  #      dict(AttributeName)   For example: STATE=ONLINE
  # ----------------------------------------------------------------------------
  print('Processing service name attributes from OCR.')
  if (options.Replay):
    RegisteredSvcData = open(pklRegisteredSvcData,'rb')
    RegisteredSvcDD = pickle.load(RegisteredSvcData)
    RegisteredSvcData.close()

    RegSvcProvSchemeData = open(pklRegSvcProvSchemeData,'rb')
    RegSvcProvSchemeDD = pickle.load(RegSvcProvSchemeData)
    RegSvcProvSchemeData.close()
  else:
    Crsctl_p_Stdout = GetCrsctlStatPOutput()
    RegisteredSvcDD, RegSvcProvSchemeDD = GetRegisteredSvcAttributes(Crsctl_p_Stdout, RegisteredDbDD)

  if (options.TraceLevel >= 1):
    PrintRegSvcProvSchemeDD(RegSvcProvSchemeDD)
    if (options.TraceLevel >= 2):
      PrintRegisteredSvcDD(RegisteredSvcDD)

  if (options.ServiceDetlRpt):
    # Pull Service Name details using srvctl status service ...
    # This section of code is finished (except for some needed error checking
    # for the output of the 'srvctl config service' command. The RegSvcDetailDD
    # data will allow you to associate 'Preferred/Available' service state with
    # the provisioning codes P, A, F in improv.ini, and the enabled/disabled
    # instances. The code to verify and report this relationship has not been
    # yet been written.
    # ----------------------------------------------------------------------------
    print('Extracting detailed service name information from OCR.')
    print(' This can take several minutes depending on the number of service names defined...')
    if (options.Replay):
      # Use Pickled Data
      SvcDetailData = open(pklSvcDetailData,'rb')
      RegSvcDetailDD = pickle.load(SvcDetailData)
      SvcDetailData.close()

      SvcDetailProvSchemeData = open(pklSvcDetailProvSchemeData,'rb')
      RegSvcDetailProvSchemeDD = pickle.load(SvcDetailProvSchemeData)
      SvcDetailProvSchemeData.close()
    else:
      RegSvcDetailDD, RegSvcDetailProvSchemeDD = GetServiceDetails(RegSvcProvSchemeDD, RegisteredDbDD)

    if (options.TraceLevel >= 2):
      PrintRegSvcDetailDD(RegSvcDetailDD)
      print('')

  # Read Configuration file values from improv.ini
  # -----------------------------------------------
  try:
    # The next two lines check to see if there is a config file and that I can read it.
    # If I can't find/read the ini file then throw and exception and exit(1).
    IniFile = open(ImprovIni,'rb')
    IniFile.close()
    # The following line silently opens and loads the ini file into a Config object.
    Config.read(ImprovIni)
  except:
    formatExceptionInfo()
    print("Cannot read configuration file: " + ImprovIni)
    exit(1)
  
  # Load up the database settings from the ini file.
  # ------------------------------------------------------------
  print('Loading provisioning plan from ' + ImprovIni + '.')
  ProvisionedDD, ProvSchemeDD = ReadConfig()
  if (options.TraceLevel >= 1):
    PrintProvSchemeDD(ProvSchemeDD)
    print('')
    if (options.TraceLevel >= 2):
      PrintProvisionedDD(ProvisionedDD)
      print('')

  # Import the provisioning plan from the Excel csv file.
  # ------------------------------------------------------------
  if (options.ImportPlan):
    print('Importing Provisioning Plan from ' + ImpFilename)
    ImpDD = ImportPlan(ImpFilename)

    if (options.TraceLevel >= 1):
      PrintImportedConfig(ImpDD)

    print('Generating merged Plan from imported ' + ImpFilename + ' to ' + MergeImportedFilename)
    MergeImportedConfig(ProvisionedDD, ImpDD, MergeImportedFilename)

  ###~ # Export the provisioning plan from to Excel csv file.
  ###~ # ------------------------------------------------------------
  ###~ if (options.ExportPlan):
  ###~   ExportPlan(ProvisionedDD, ExpFilename)

  # Extract runtime memory & configuration information from each database.
  # ----------------------------------------------------------------------------
  if (options.ProbeDbs):
    print('Polling databases for instance memory parameters.')
    if (options.Replay):
      RunningDbInfoData = open(pklRunningDbInfoData,'rb')
      RunningDbInfoDD = pickle.load(RunningDbInfoData)
      RunningDbInfoData.close()
    else:
      RunningDbInfoDD = GetRunningDbInfo(ProvisionedDD)

    print('Comparing actual memory & storage utilization with provisioning schemes.')
    PassedParmsDD, FailedParmsDD = CheckParms(ProvisionedDD, RunningDbInfoDD)

    MergeRunningConfig(ProvisionedDD, RunningDbInfoDD, MergeRunningFilename)

    if (options.TraceLevel >= 1):
      PrintRunningDbInfoDD(RunningDbInfoDD)
      
  print('Comparing actual database configuration with provisioning plan.')
  PassedProvDbCheckLL, PassedRegDbCheckLL, FailedProvDbCheckLL, FailedRegDbCheckLL = CheckProvDbRegistered(ProvSchemeDD, RegDbProvSchemeDD)

  print('Comparing actual service name configuration with provisioning plan.')
  PassedProvSvcCheckLL, FailedProvSvcCheckLL = CheckProvSvcRegistered(ProvSchemeDD, RegSvcProvSchemeDD)

  # Pickle your data for replay at a later time.
  if (not options.Replay):
    RegisteredServerPoolData = open(pklRegisteredServerPoolData,'wb')
    pickle.dump(RegisteredServerPoolDict, RegisteredServerPoolData)
    RegisteredServerPoolData.close()

    RegisteredNodeListData = open(pklRegisteredNodeListData,'wb')
    pickle.dump(RegisteredNodeListOfDict, RegisteredNodeListData)
    RegisteredNodeListData.close()

    RegDbProvSchemeData = open(pklRegDbProvSchemeData,'wb')
    pickle.dump(RegDbProvSchemeDD, RegDbProvSchemeData)
    RegDbProvSchemeData.close()

    RegisteredDbData = open(pklRegisteredDbData,'wb')
    pickle.dump(RegisteredDbDD, RegisteredDbData)
    RegisteredDbData.close()

    RegisteredSvcData = open(pklRegisteredSvcData,'wb')
    pickle.dump(RegisteredSvcDD, RegisteredSvcData)
    RegisteredSvcData.close()

    RegSvcProvSchemeData = open(pklRegSvcProvSchemeData,'wb')
    pickle.dump(RegSvcProvSchemeDD, RegSvcProvSchemeData)
    RegSvcProvSchemeData.close()

    if (options.ServiceDetlRpt):
      SvcDetailData = open(pklSvcDetailData,'wb')
      pickle.dump(RegSvcDetailDD, SvcDetailData)
      SvcDetailData.close()

      SvcDetailProvSchemeData = open(pklSvcDetailProvSchemeData,'wb')
      pickle.dump(RegSvcDetailProvSchemeDD, SvcDetailProvSchemeData)
      SvcDetailProvSchemeData.close()

    if (options.ProbeDbs):
      RunningDbInfoData = open(pklRunningDbInfoData,'wb')
      pickle.dump(RunningDbInfoDD, RunningDbInfoData)
      RunningDbInfoData.close()

  # Export the provisioning plan from to Excel csv file.
  # ------------------------------------------------------------
  if (options.ExportPlan):
    ExportPlan(ProvisionedDD, ExpFilename)

  # Print Reports
  print('Printing provisioning report.')
  if (options.ProbeDbs):
    print('')
    ReportDatabaseInfo(RunningDbInfoDD)
    if (options.Verbose):
      print('')
      ReportPassedParms(PassedParmsDD)
    print('')
    ReportFailedParms(FailedParmsDD)

  print('')
  PrintProvSchemeReport(ProvSchemeDD, RegisteredNodeListOfDict)

  if (options.Verbose):
    print('')
    ReportPassedProvDbCheck(PassedProvDbCheckLL)

  print('')
  ReportFailedProvDbCheck(FailedProvDbCheckLL)

  print('')
  ReportFailedRegDbCheck(FailedRegDbCheckLL)

  if (options.Verbose):
    print('')
    ReportPassedRegDbCheck(PassedRegDbCheckLL)

  if (options.Verbose):
    print('')
    ReportPassedProvSvcCheck(PassedProvSvcCheckLL)

  print('')
  ReportFailedProvSvcCheck(FailedProvSvcCheckLL)

  if (options.ServiceDetlRpt):
    print('')
    ReportRegSvcDetailProvSchemeDD(RegSvcDetailProvSchemeDD)

  if (options.GenCommands):
    GenerateProvisioningCommands(ProvisionedDD, RegisteredNodeListOfDict)

  print('\n============================================================================================================================');
  print('End of Report                                                                   %44s' % (Now.strftime("%Y-%m-%d %H:%M")));
  print('============================================================================================================================');

  exit(0)

