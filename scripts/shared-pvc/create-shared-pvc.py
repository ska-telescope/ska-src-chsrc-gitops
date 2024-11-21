"""
This tool generates Kubernetes YAML manifests for duplicating a PersistentVolumeClaim (PVC) 
to another namespace. It creates a new PVC and PersistentVolume (PV) that reference the 
same underlying storage as the original PVC, ensuring data is shared between namespaces. 
It assumes that there's an existing context to the cluster that it will use to fetch existing resources.
It outputs the corresponding PV/PVC pair as yaml to stdout.
"""
from kubernetes import client, config
from kubernetes.client import ApiClient
import argparse
import yaml

def parse_namespace_and_name(arg):
    """
    Parse an argument of the form namespace/pvc_name into namespace and name.
    """
    if "/" not in arg:
        raise ValueError(f"Invalid format: {arg}. Expected format is namespace/pvc_name.")
    namespace, name = arg.split("/", 1)
    return namespace, name

def clean_the_nulls(obj):
    """
    Recursively remove fields set to `None` or `null` in a dictionary.
    """
    if isinstance(obj, dict):
        return {k: clean_the_nulls(v) for k, v in obj.items() if v not in [None, {}]}
    elif isinstance(obj, list):
        return [clean_the_nulls(v) for v in obj if v not in [None, {}]]
    else:
        return obj

def fetch_and_generate_yaml(original, new, context=None):
    # Load kubeconfig
    if context:
        config.load_kube_config(context=context)
    else:
        config.load_kube_config()

    # Parse arguments
    original_namespace, original_pvc_name = original
    new_namespace, new_pvc_name = new

    # Initialize API clients
    core_v1 = client.CoreV1Api()
    api_client = ApiClient()

    # Step 1: Get the original PVC
    try:
        original_pvc = core_v1.read_namespaced_persistent_volume_claim(
            name=original_pvc_name, namespace=original_namespace
        )
    except client.exceptions.ApiException as e:
        print(f"Error fetching original PVC: {e}")
        return

    # Step 2: Get the associated PV
    original_pv_name = original_pvc.spec.volume_name
    try:
        original_pv = core_v1.read_persistent_volume(name=original_pv_name)
    except client.exceptions.ApiException as e:
        print(f"Error fetching associated PV: {e}")
        return

    # Step 3: Create a new PV object
    new_pv_name = f"{original_pv_name}-{new_namespace}"
    new_pv = client.V1PersistentVolume(
        metadata=client.V1ObjectMeta(name=new_pv_name),
        spec=original_pv.spec,
    )
    new_pv.spec.claim_ref = None  # Remove claimRef
    # Add apiVersion and kind
    new_pv_dict = api_client.sanitize_for_serialization(new_pv)
    new_pv_dict["apiVersion"] = "v1"
    new_pv_dict["kind"] = "PersistentVolume"

    # Step 4: Create a new PVC object
    new_pvc = client.V1PersistentVolumeClaim(
        metadata=client.V1ObjectMeta(name=new_pvc_name, namespace=new_namespace),
        spec=client.V1PersistentVolumeClaimSpec(
            access_modes=original_pvc.spec.access_modes,
            resources=original_pvc.spec.resources,
            storage_class_name=original_pvc.spec.storage_class_name,
            volume_mode=original_pvc.spec.volume_mode,
            volume_name=new_pv_name,
        ),
    )
    # Add apiVersion and kind
    new_pvc_dict = api_client.sanitize_for_serialization(new_pvc)
    new_pvc_dict["apiVersion"] = "v1"
    new_pvc_dict["kind"] = "PersistentVolumeClaim"

    # Serialize to YAML using the ApiClient's serialization helper.
    # to_dict has issues because it produces snake_case instead of the kubernetes manifest snakeCase for resources.
    new_pv_yaml = yaml.dump(new_pv_dict,default_flow_style=False)
    new_pvc_yaml = yaml.dump(new_pvc_dict, default_flow_style=False)

    print("---")
    print(new_pv_yaml)
    print("---")
    print(new_pvc_yaml)

def main():
    parser = argparse.ArgumentParser(
        description="Generate Kubernetes YAML for duplicating a PVC to another namespace."
    )
    parser.add_argument(
        "original",
        help="The original PVC in the format namespace/pvc_name."
    )
    parser.add_argument(
        "new",
        help="The new PVC in the format namespace/pvc_name."
    )
    parser.add_argument(
        "--context",
        help="The Kubernetes context to use (as defined in kubeconfig).",
        default=None
    )

    args = parser.parse_args()

    # Parse namespace and name from the positional arguments
    try:
        original = parse_namespace_and_name(args.original)
        new = parse_namespace_and_name(args.new)
    except ValueError as e:
        parser.error(str(e))
        return

    fetch_and_generate_yaml(original, new, context=args.context)

if __name__ == "__main__":
    main()
