rm -rf results
# 
# Two conditions must hold for us to move 'working' folder to 'today'
#  1. the 'working' folder is valid, ..workingFolder.isValid?()=true
#  2. the 'today' folder is NOT valid, ..todayFolder.isValid?()=true
# In this case, we can move 'working' folder to 'today'
#
rm -rf working
mkdir working
mkdir results
# Permits script
unset SKIP_PERMITS
export SKIP_PERMITS=1
# Crimes script
unset SKIP_CRIMES
export SKIP_CRIMES=1
# all done
