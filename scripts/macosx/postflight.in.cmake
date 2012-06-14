#!/bin/sh

##############################################################################
#
#  Post Install file for MySQL Connector ODBC 5.2
#
##############################################################################

# ----------------------------------------------------------------------
# ENSURE WE HAVE INI FILES
#
# Upon a fresh install of OS X these files do not exist. The ODBC Installer
# library calls should create these files for us when we do stuff like
# request to register a driver but this does not seem to happen and the
# request fails. So we we start by making sure we have some, mostly, empty
# ini files in place before we make installer calls.
#
# Also note that there are many places where these ini files *could* go
# based upon the search algorithm in the default ODBC system or any other
# ODBC system which may get installed. We choose the following because they
# seem to be the ones created when we use the standard ODBC Administrator
# application.
# ----------------------------------------------------------------------

libdir=/usr/local/lib
bindir=/usr/local/bin

for admdir in ~/Library/ODBC /Library/ODBC
do
  echo "Ensuring $admdir, odbcinst.ini and odbc.ini exists..."
  if [ ! -d $admdir ] ; then
      mkdir $admdir
      chmod 775 $admdir
      chown root:admin $admdir
  fi

  if [ ! -f $admdir/odbc.ini ] ; then
      echo "[ODBC Data Sources]"        > $admdir/odbc.ini
      echo ""                          >> $admdir/odbc.ini
      echo "[ODBC]"                    >> $admdir/odbc.ini
      echo "Trace         = 0"         >> $admdir/odbc.ini
      echo "TraceAutoStop = 0"         >> $admdir/odbc.ini
      echo "TraceFile     ="           >> $admdir/odbc.ini
      echo "TraceLibrary  ="           >> $admdir/odbc.ini
      chmod 664 $admdir/odbc.ini
      chown root:admin $admdir/odbc.ini
  fi

  if [ ! -f $admdir/odbcinst.ini ] ; then
      echo "[ODBC Drivers]"             > $admdir/odbcinst.ini
      echo ""                          >> $admdir/odbcinst.ini
      echo "[ODBC Connection Pooling]" >> $admdir/odbcinst.ini
      echo "PerfMon    = 0"            >> $admdir/odbcinst.ini
      echo "Retry Wait = "             >> $admdir/odbcinst.ini
      chmod 664 $admdir/odbcinst.ini
      chown root:admin $admdir/odbcinst.ini
  fi
done

# ----------------------------------------------------------------------
# SET USER PERMISSIONS
#
# Note that if the Mac OS X "ODBC Administrator" is run before this
# script, and unlocked (root rights), it would save files in the user
# area with root permissions, causing trouble later when trying to
# change user settings without unlocking (root rights).
# ----------------------------------------------------------------------
if [ "$USER" -a "$GROUPS" ] ; then
    chown -R $USER:$GROUPS ~/Library/ODBC
fi

# ----------------------------------------------------------------------
# REGISTER THE DRIVER
# ----------------------------------------------------------------------
echo "Registering driver..."
#$bindir/myodbc-installer -a -d -n "MySQL ODBC 5.1 Driver" -t "Driver=$libdir/libmyodbc5@CONNECTOR_DRIVER_TYPE_SHORT@.so;Setup=$libdir/libmyodbc3S.so;"
$bindir/myodbc-installer -a -d -n "MySQL ODBC 5.1 Driver" -t "Driver=$libdir/libmyodbc5@CONNECTOR_DRIVER_TYPE_SHORT@.so;"

# ----------------------------------------------------------------------
# CREATE A SAMPLE DSN
# ----------------------------------------------------------------------
echo "Ensuring sample data source name (myodbc) exists..."
$bindir/myodbc-installer -a -s -n myodbc -t "Driver=MySQL ODBC 5.2 Driver;SERVER=localhost;"