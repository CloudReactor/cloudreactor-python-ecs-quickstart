# Alerts

If you want to be alerted if task executions fail, you'll need to set up an 
Alert Method. An Alert Method links to one or more ways of sending notifications
when certain events occur.

Currently, the only supported notification type is sending PagerDuty events.
[PagerDuty](https://pagerduty.com) is powerful because it supports many ways
of forwarding events once it receives them, for example sending an SMS message,
sending an email, or sending a message to a Slack channel.

To have CloudReactor send task and workflow events to PagerDuty, follow these 
general steps:

* Create a PagerDuty Profile
* Create an Alert Method
* Add the Alert Method to one or more Tasks or Workflows

## Create a PagerDuty Profile

First, create a PagerDuty Profile that contains configuration on how to
connect to your PagerDuty account.

1. If you haven't already, create an account with PagerDuty
2. Login to your PagerDuty account
3. Choose the menu option `Configuration ... Services`. On that page 
select the `+ New Service` button to add a new Service.
4. Name your Service anything you desire. Under Integration Settings ... Integration Type, select "Use our API directly" and ensure that 
`Events API v2` is selected. If desired, adjust the Incident Settings.
Finally, select the `Add Service` button at the page.
5. On the next page you'll see your newly created Service along with an Integration Key. Copy the Integration Key for use in CloudReactor.
6. In the [CloudReactor](https://processescloudreactor.io/) website, 
select your username in the top right corner to reveal a dropdown menu. Select `PagerDuty profiles`. 
7. On the next page, select the `Add PagerDuty Profile` button.
8. You'll be taken to a form that lets you create the profile. Enter a
name, and optionally a description. In the `Integration key` field,  paste in the Integration Key you copied from PagerDuty in step 5. For the 
`Default event severity` field, choose the PagerDuty event severity to 
use for events with no explicit severity. By default, this is `Error`.
9. Select the `Save` button to save the profile 

## Create an Alert Method

Next, create an Alert Method that will link to the PagerDuty Profile you just
created.

1. In the [CloudReactor](https://processescloudreactor.io/) website, 
select your username in the top right corner to reveal a dropdown menu. Select `Alert methods`. 
2. On the next page, select the `Add Alert Method` button.
3. You'll be taken to a form that lets you create the Alert Method. Enter a
name, and optionally a description.
4. Leave the Enabled checkbox checked to ensure this Alert Method is fired
when events occur.
5. Choose the desired event severity when: 
    * Scheduled Task or Workflow executions don't start; 
    * Tasks do not send heartbeats on time; and
    * A service goes down
6. In the field labeled 
`Which PagerDuty Profile should this Alert Method be linked to?`,
select the PagerDuty Profile you created above.
7. For the field labeled `Default event severity`, choose the PagerDuty event severity to use for events with no explicit severity. By default, this is `Error`.
8. Select the `Save` button to save the Alert Method

## Add the Alert Method to one or more Tasks or Workflows

Finally, you just need to associate your Tasks or Workflow to the Alert Method you created.

### Setting the Alert Method for Tasks

For Tasks, you'll need to edit the task configuration that you send to 
CloudReactor when you deploy your project. In 
`deploy/common.yml` you can set the default Alert Methods
for all tasks and all environments in `default_task_config`, or the Alert Methods for each task in all all environments in `task_name_to_config.<task_name>.alert_methods`. The
`alert_methods` property should be set to a list of the name(s) of 
the Alert Methods you created above. You can also set the Alert
Methods of a task in your deployment environment configuration
file, for example `deploy/staging.yml`. In that file you can 
set the alert methods for the whole environment in `default_env_task_config.alert_methods`, or per task in 
`task_name_to_env_config.<task_name>.alert_methods`.

Support for editing the Alert Methods for each Task on the website
is planned, but not available yet.

### Setting the Alert Method for Workflows

For Workflows, you can set the Alert Methods on the CloudReactor 
website:

1. To go the list of your Workflows by selecting `Workflows` in the top
navigation bar.
2. Click on the Workflow you want to set the Alert Method on
3. On the Workflow detail page, click the `Settings` tab
4. For the `Alert Methods` field, check all the checkboxes next to the
Alert Methods you want to associate with the Workflow
