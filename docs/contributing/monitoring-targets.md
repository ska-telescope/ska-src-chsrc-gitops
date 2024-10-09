# Registering Your Global Monitoring Targets

To register your services for global monitoring, please follow these steps:

1. Navigate to the [targets folder on the dev branch](https://gitlab.com/ska-telescope/src/deployments/chsrc/ska-src-chsrc-services-cd/-/tree/dev/apps/kube-prometheus-stack/overlays/dev/targets).
2. Open the `values.yaml` file, which contains all the scraping targets.
3. (Unless you're cloning this repo to make edits) Click on **Edit** &rarr; **Open in Web IDE** to edit the targets.
4. Locate your section. As of October 2024, some fields should already be prefilled for you, but please double-check everything.
5. Make your changes and commit them to a **new branch**. Please remember to adhere to the [SKAO conventions for pushing code](https://developer.skatelescope.org/en/latest/howto/push_branch.html#push-code-branch). Additionally, read the [Contributing to the repository](repo.md) section carefully to avoid issues with Marvin's CI bot.
6. Once you are satisfied with your changes, create a merge request (MR) into the `dev` branch, again following the aforementioned conventions.
7. We will review your MR in due course. If you feel that your MR has been overlooked or if you wish to expedite the process, please reach out to any member of the Chocolate Team or message us all in our Slack channel.

If you encounter any issues, don’t hesitate to ask for assistance!

### A Few More Things to Consider for New Services
- Please stick to the following format when adding your services:

    ```yaml
    - targets:
        - https://example.url.org/
      labels:
        servicename: 'example-service'
    ```
- Do **not** change nor substitute any values under the section `relabel_configs:`. It's magic that's required to integrate with our monitoring infrastructure.

- When adding a new site, please copy and paste an existing site and make the following changes:

    1. Ensure `job_name` is unique (consider using `<site>-blackbox`).
    2. Adjust the `target_label: location` replacement to match your specific site.
    3. Change all service references to the services you want to monitor.
  
Make sure to review all relevant fields!
