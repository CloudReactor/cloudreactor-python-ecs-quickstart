# Troubleshooting

* If you are using Native Deployment on Mac OS X, and see the message:

  Abort trap: 6

follow the steps on https://dbaontap.com/2019/11/11/python-abort-trap-6-fix-after-catalina-update/
to fix, possibly, replacing 1.0.2t with 1.0.2s or whatever you have in 
```/usr/local/Cellar/openssl/1.0.2s/lib```.

* If you are using Native Deployment on Mac OS X, and see the error 
"ERROR:root:code for hash md5 was not found.", you may need to
run the command

    brew switch openssl 1.0.2s

See [StackOverflow](https://stackoverflow.com/questions/59269208/errorrootcode-for-hash-md5-was-not-found-when-using-any-hg-mercurial-command) for more details   

If you encounter any other problems, feel free to reach out to us at support@cloudreactor.io!
