ggsci <<EOF
add credentialstore
alter credentialstore add user gg_extract@datasource:1521/xe password gg_extract alias oggext
dblogin useridalias oggext
add schematrandata trans_user ALLCOLS
Exit
EOF

cp /shared/getext.prm /u01/app/ogg/dirprm/
cp /shared/pumpext.prm /u01/app/ogg/dirprm/


ggsci <<EOF
ADD EXTRACT getExt, TRANLOG, BEGIN NOW  
ADD EXTTRAIL ./dirdat/in, EXTRACT getext  
START EXTRACT getExt  
info extract getext, detail
EOF


ggsci <<EOF
add extract pumpext, EXTTRAILSOURCE ./dirdat/in, begin now
add rmttrail /opt/oggbd/dirdat/in, extract pumpext, megabytes 50
start pumpext
info extract pumpext, detail
EOF
