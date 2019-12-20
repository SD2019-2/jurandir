import yaml

with open('config.yaml', 'r') as F:
    config = yaml.load(F, Loader=yaml.FullLoader)