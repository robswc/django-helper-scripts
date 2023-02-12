#!/bin/bash
version="1.0.0"
name="backend.sh"

# Sets up an existing Django project with common backend add-ons

python_packages="djangorestframework django-cors-headers drf-yasg whitenoise"

# check if python is installed
if ! command -v python &>/dev/null; then
  echo "Python could not be found"
  exit
fi

# Prompt the user for the name of the project
read -p "Enter the name of the Django project (hit enter for current directory): " project_name

# check if project name is empty
if [ -z "$project_name" ]; then
  # set project name current folder name if empty
  project_name=$(basename "$PWD")
fi

# Install packages using pip
pip install $python_packages

# check to see if file exists
if [ -f "${project_name}"/settings.py ]; then
  echo "Settings File exists"
else
  # prompt user to create a new project
  read -p -r "File does not exist. Would you like to create a new project? (y/n): " create_project
  if [ "$create_project" == "y" ]; then
    # create a new project
    django-admin startproject "${project_name}"
  else
    # exit the script
    exit 1
  fi
fi

# modify Django settings file to add necessary additions
echo "Modifying Django settings file..."
echo -e "\n\n# Added by $name $version (@robswc)" >>"${project_name}"/settings.py
echo "INSTALLED_APPS += ['drf_yasg', 'corsheaders']" >>"${project_name}"/settings.py
echo "MIDDLEWARE += ['corsheaders.middleware.CorsMiddleware', 'django.middleware.common.CommonMiddleware']" >>"${project_name}"/settings.py
echo "MIDDLEWARE += ['whitenoise.middleware.WhiteNoiseMiddleware']" >>"${project_name}"/settings.py
echo 'STATIC_ROOT = BASE_DIR / "staticfiles"' >>"${project_name}"/settings.py
echo "CORS_ALLOWED_ORIGINS = ['http://localhost:8000', 'http://127.0.0.1:8000']" >>"${project_name}"/settings.py

# modify urls.py file to add necessary additions
echo "Modifying urls.py file..."

sed -i 's/from django.urls import path/from django.urls import path \nfrom drf_yasg.views import get_schema_view \nfrom drf_yasg import openapi \nfrom rest_framework import permissions/' "${project_name}"/urls.py
sed -i '/from rest_framework import permissions/a schema_view = get_schema_view( \n   openapi.Info( \n      title="API", \n      default_version="v1", \n      description="API", \n      terms_of_service="https://www.google.com/policies/terms/", \n      contact=openapi.Contact(email=""),), \n   public=True, \n   permission_classes=[permissions.AllowAny])' "${project_name}"/urls.py
sed -i 's/from django.urls import path/from django.urls import path, re_path/' "${project_name}"/urls.py

# add swagger urls
sed -i '/urlpatterns = \[/a re_path(r"^swagger(?P<format>\.json|\.yaml)$", schema_view.without_ui(cache_timeout=0), name="schema-json"), \nre_path(r"^swagger/$", schema_view.with_ui("swagger", cache_timeout=0), name="schema-swagger-ui"), \nre_path(r"^redoc/$", schema_view.with_ui("redoc", cache_timeout=0), name="schema-redoc"),' "${project_name}"/urls.py

echo "Finished..."
