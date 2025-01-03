{lib, ...}: let
  projects = import ./projects;

  validateProject = name: project:
    if project.project.repo != null && project.project.docker_image != null
    then project
    else builtins.throw "Missing attributes: 'repo' or 'docker_image' in '${name}'.";

  validatedProjects = builtins.mapAttrs (name: project: validateProject name project) projects;

  grouped =
    lib.foldl'
    (
      acc: name: project: let
        group = project.project.type or "default";
      in
        acc
        // {
          ${group} = (acc.${group} or []) ++ [project];
        }
    ) {} (lib.attrNames validatedProjects) (lib.attrValues validatedProjects);
in
  validatedProjects
