set escape on
show escape
update freightlabels set html=replaceclob(html, '\&type=1''>','\&type=1\&from=auto''>')
/
