# Manual Testing Plan

The purpose of the document is to highlight the setups steps and scenarios of concern that will be prioritized in order to jump start the testing cycles needed for Cobalt deployments.

## Setup

Follow the [portal-based walkthrough](./GETTING_STARTED_ADD_PAT_OWNER.md). as a guide for installing the iso template to run through the below scenarios. <!--Pending comments about backendstate and which documentation instructions to follow (add pat owner vs fork and go)-->

### Scenario 1 - Parallel Deployments for ISO Template

#### Description

In an enterprise scenario, it's expected that a team will be deploying templates in parallel with other teams. Setup at least 4 simultaneous deployments, one pipeline per AZDO project and document any shortcomings along the way.

![image](https://user-images.githubusercontent.com/10041279/64363288-d597f480-cfd5-11e9-8bf4-ab1ae5864370.png)

#### Scenario #1 Test Plan

All can be independent instances of the echo-server. Can run under the Hosted Ubuntu AGENT_POOL (no need to use the custom agent pool described elsewhere).

Do the following four (or more) times:
1. Create a new AZ DO Project
1. Import the `microsoft/cobalt` repo
1. Using the portal editor or otherwise, alter vars to be unique to this project & pipeline
1. Trigger the pipelines
1. Trigger the container depoyments (`acr build/push`)
1. Test that the frontend and backend endpoints are echoing for each project/instance

-----

### Scenario 2 - Naming Collision Fix for ISO Template

#### Description

Naming collisions are a current problem in Cobalt template deployments. Setting up scenario 1 will allow for the testing cycles needed to resolve this problem.

------

### Scenario 3 - Multiple Deployment Targets for ISO Template

#### Description

Validate template can properly configure the webhooks and values needed for at least 5 multiple app service deployment targets (contained with the .tfvars file) within a single pipeline deployment. Deployment targets are divided by authentication and non-authenticated types but all reference echo servers at the moment. If done correctly, the final step would be 5 manual image pushes to acr and a visit to each app service url to validate a container is running.

![image](https://user-images.githubusercontent.com/10041279/64363447-50610f80-cfd6-11e9-8a39-7a092db98006.png)

#### Scenario #3 Test Plan

1. Create a fork of `microsoft/cobalt` (do not alter the public repo with a branch, etc.)
1. Create a pipeline to point to the fork
1. Alter vars to be unique to this test
1. Alter `unauthn_deployment_targets` and `authn_deployment_targets` to have an array of 2+ deployment targets, each
1. Trigger the pipeline
1. Trigger the container depoyments (`acr build/push`)
1. Test that the frontend and backend endpoints are echoing

------

### Scenario 4 - Setup custom hosted agent pool with self-hosted linux agent

#### Description

An enterprise will likely want full control of deployment machines and opt to have self-hosted linux agent. Test deployments without reliance on agent pools provided by ADO.

Helpful Installation Link: [Installing Self Hosted Linux Agent](https://docs.microsoft.com/en-us/azure/devops/pipelines/agents/v2-linux?view=azure-devops)

#### Scenario #4 Test Plan

1. Create an Ubuntu VM
1. Install the self-hosted linux agent
1. Configure the self-hosted linux agent
1. Create a fork of `microsoft/cobalt` (do not alter the public repo with a branch, etc.)
1. Create a pipeline to point to the fork
1. Alter vars to be unique to this project & pipeline
1. Alter the AGENT_POOL 'Infrstructure Pipeline' variable to point to the custom build VM
1. Trigger the pipelines
1. Trigger the container deployments (`acr build/push`)
1. Test that the frontend and backend endpoints are echoing for each project/instance

------

### Scenario 5 - Deploy simple NGINX example via ISO Template 

#### Description

We need to demonstrate running NGINX as another example application. 
We'll use the official Docker image for nginx from https://hub.docker.com/_/nginx

#### Scenario #5 Test Plan

_*Open question:*_ can ISO work from docker hub directly (vs needed ACR?) Perhaps we'll need to 
push the nginx image to ACR to test this.

1. Create a fork of `microsoft/cobalt` (do not alter the public repo with a branch, etc.)
1. Create a pipeline to point to the fork
1. Alter vars to be unique to this test
1. Alter `unauthn_deployment_targets` and `authn_deployment_targets` to point to the nginx image
1. Trigger the pipeline
1. Trigger the container deployments (`acr build/push`) _(what is the right way to do this?)_
1. Test that the frontend and backend endpoints are hosting the default nginx page.