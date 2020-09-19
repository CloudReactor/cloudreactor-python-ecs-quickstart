# Troubleshooting

* When deploying, you see 

    AnsibleFilterError: |combine expects dictionaries, got None"}
    
This may be caused by defining a property like a task under `task_name_to_config`
in `deploy/vars/common.yml`:

    task_name_to_config:
       some_task:
       another_task:
         schedule: cron(9 15 * * ? *) 

`some_task` is missing a dictionary value so the corrected version is:

    task_name_to_config:
       some_task: {}
       another_task:
         schedule: cron(9 15 * * ? *) 
                      

* Incorrect configuration:
It's possible that you overrode a Task setting during a previous deployment, but 
later decide to use the default value in the Run Environment. 
To do that, set the property value to null. If things still aren't working,
try removing the Task in the CloudReactor website, and re-deploying again.

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
