# infra
# assignment 1 - deploy nginx on ecs with container insgiht 
# screen shot:
![image](https://github.com/user-attachments/assets/a946a611-831f-49ec-9f76-fa964ca96d2c)
------
# to run the ecs infra:

    cd ./products/ecs_project_assignment1/us-east-1/qa/shared/ecs/
    terragrunt run-all apply --terragrunt-non-interactive
# to run the eks:
     cd ./products/project/eu-central-1/prod/
     terragrunt run-all apply --terragrunt-non-interactive
