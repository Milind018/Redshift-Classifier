import subprocess
import os
import streamlit as st
import pandas as pd
from PIL import Image
import re

def run_r_script(script_name, input_file=None, output_file=None, apply_mice=None, upsampling=None, m_estimator=None, custom_models=None, m_est_weight=None, n_loops = None,
                 correlation_cutoff=None, RMSE_cutoff=None, supmodel=None, glmb=None, cutoff = None, wcutoff = None):
    """
    Run an R script with optional arguments for output file,
    and additional optional arguments for applying MICE, m_estimator and removing catastrophic outliers.
    """
    #command = ["/Library/Frameworks/R.framework/Resources/bin/Rscript", script_name]# for mac
    command = ["Rscript", script_name] # R.home() any for linux or windows
    if output_file is not None:
        command.append(output_file)

    if input_file is not None:
        command.append(input_file)
    
    if apply_mice is not None:
        command.append(str(apply_mice))

    if upsampling is not None:
        command.append(str(upsampling))

    if m_estimator is not None:
        command.append(str(m_estimator))

    if custom_models is not None:
        command.append(str(custom_models))

    if m_est_weight is not None:
        command.append(str(m_est_weight))

    if n_loops is not None:
        command.append(str(n_loops))

    if correlation_cutoff is not None:
        command.append(str(correlation_cutoff))

    if RMSE_cutoff is not None:
        command.append(str(RMSE_cutoff))
    
    if cutoff is not None:
        command.append(str(cutoff))

    if wcutoff is not None:
        command.append(str(wcutoff))

    subprocess.run(command, check=True)

def clean_up(*file_paths):
    """Delete temporary files."""
    for file_path in file_paths:
        if os.path.exists(file_path):
            os.remove(file_path)

def convert_rmd_to_r(rmd_file, r_file):
    """
    Convert an R Markdown (.rmd) file to an R script (.r) file by extracting R code chunks.
    
    Parameters:
    - rmd_file: str, path to the .rmd file
    - r_file: str, path to the output .r file
    """
    with open(rmd_file, 'r') as file:
        content = file.read()

    # Regular expression to extract R code chunks
    code_chunks = re.findall(r'```{r.*?}(.*?)```', content, re.DOTALL)
    
    # Join all extracted code chunks
    r_code = "\n".join(code_chunks)

    with open(r_file, 'w') as file:
        file.write(r_code)

    print(f"Converted {rmd_file} to {r_file}")


# Example of how you might call this function
# run_rmd_script("your_script.Rmd", output_file="output.html", apply_mice=True)

subprocess.run(["Rscript", "install_r2u.R"], check=True)

st.title("**Redshift Classifier**")

use_m_estimator = "No"
use_mice = "No"
apply_smote = "No"


st.write("**Please provide Raw X-ray data**")
use_m_estimator = st.selectbox("Use M-Estimator?", ["No", "Yes"])

if use_m_estimator == "Yes":
        weight_cutoff = st.slider("Set Weight Cutoff:", 0.0, 1.0, 0.65, step=0.05)
        st.write(f"Weight cutoff is set to: {weight_cutoff}")
        # Second Dropdown: If M-Estimator is used, do MICE or not
        use_mice = st.selectbox("Apply MICE?", ["No", "Yes"])
    
        if use_mice == "Yes":
            # Third Dropdown: If MICE is used, apply SMOTE balancing or not
            apply_smote = st.selectbox("Apply SMOTE Balancing?", ["No", "Yes"])

            if apply_smote == "Yes":
                st.write("You chose to use M-Estimator, apply MICE, and apply SMOTE balancing.")
            else:
                st.write("You chose to use M-Estimator, apply MICE, but not apply SMOTE balancing.")
        else:
            st.write("You chose to use M-Estimator but not apply MICE.")
else:
        st.write("You chose not to use M-Estimator.")

redshift_cutoff = st.slider('Choose Redshift Cutoff',
min_value=2.0,  # minimum value
max_value=4.0,  # maximum value
value=3.0,      # default value
step=0.1        # step size
)

uploaded_file = st.file_uploader("**Choose a file (.csv or .txt)**", type=['csv', 'txt'])
process_file = st.button("**Submit**")

if uploaded_file is not None and process_file:
        if use_m_estimator == "No" and use_mice == "No" and apply_smote == "No":
            plot_dir = "CURRENT_ANALYSIS/Graphics/XRAY/RAW_WITHOUT_M-estimator/"
            temp_input_file = "training_data.csv"
            with open(temp_input_file, "wb") as f:
                f.write(uploaded_file.getbuffer())
            # Example usage
            convert_rmd_to_r('data-XRAY-Classification_ON_RAW-WITHOUT-M-estimator.Rmd', 'data-XRAY-Classification_ON_RAW-WITHOUT-M-estimator.R')
            run_r_script("data-XRAY-Classification_ON_RAW-WITHOUT-M-estimator.R",temp_input_file,cutoff = redshift_cutoff)

            superlearner_plots = [os.path.join(plot_dir, filename) for filename in os.listdir(plot_dir) 
                      if filename.endswith(".png") 
                      and not (filename.startswith("AlgoRiskHisto") or filename.startswith("AlgoWeightHisto"))]
            
            #superlearner_plots = [" InvRedshiftDistribution fulldataset.png"]

            for i, plot_file in enumerate(superlearner_plots):

                if os.path.exists(plot_file):
                    image = Image.open(plot_file)
                    st.image(image)

        elif use_m_estimator == "Yes" and use_mice == "No" and apply_smote == "No":
            plot_dir = "CURRENT_ANALYSIS/Graphics/XRAY/RAW_WITH_M-estimator/"
            temp_input_file = "training_data.csv"
            with open(temp_input_file, "wb") as f:
                f.write(uploaded_file.getbuffer())
            # Example usage
            convert_rmd_to_r('M-estimator_XRAY_ON_RAW_DATA.Rmd','M-estimator_XRAY_ON_RAW_DATA.R')
            run_r_script("M-estimator_XRAY_ON_RAW_DATA.R",temp_input_file,wcutoff = weight_cutoff)
            convert_rmd_to_r('data-XRAY-Classification_ON_RAW-WITH-M-estimator.Rmd', 'data-XRAY-Classification_ON_RAW-WITH-M-estimator.R')
            run_r_script("data-XRAY-Classification_ON_RAW-WITH-M-estimator.R",cutoff = redshift_cutoff)

            superlearner_plots = [os.path.join(plot_dir, filename) for filename in os.listdir(plot_dir) 
                      if filename.endswith(".png") 
                      and not (filename.startswith("AlgoRiskHisto") or filename.startswith("AlgoWeightHisto"))]
            
            #superlearner_plots = [" InvRedshiftDistribution fulldataset.png"]

            for i, plot_file in enumerate(superlearner_plots):

                if os.path.exists(plot_file):
                    image = Image.open(plot_file)
                    st.image(image)

        elif use_m_estimator == "Yes" and use_mice == "Yes" and apply_smote == "No":
            plot_dir = "CURRENT_ANALYSIS/Graphics/XRAY/MICE_WITH_M-estimator/"
            temp_input_file = "training_data.csv"
            with open(temp_input_file, "wb") as f:
                f.write(uploaded_file.getbuffer())
            # Example usage
            convert_rmd_to_r('M-estimator_XRAY_ON_RAW_DATA.Rmd','M-estimator_XRAY_ON_RAW_DATA.R')
            run_r_script("M-estimator_XRAY_ON_RAW_DATA.R",temp_input_file,wcutoff = weight_cutoff)
            convert_rmd_to_r("MICE-Imputation_RAW-with_M-estimator.Rmd","MICE-Imputation_RAW-with_M-estimator.R")
            run_r_script("MICE-Imputation_RAW-with_M-estimator.R",temp_input_file)
            convert_rmd_to_r('data-XRAY-Classification_ON_MICE-RAW-WITH-M-estimator.Rmd', 'data-XRAY-Classification_ON_MICE-RAW-WITH-M-estimator.R')
            run_r_script("data-XRAY-Classification_ON_MICE-RAW-WITH-M-estimator.R",cutoff = redshift_cutoff)

            superlearner_plots = [os.path.join(plot_dir, filename) for filename in os.listdir(plot_dir) 
                      if filename.endswith(".png") 
                      and not (filename.startswith("AlgoRiskHisto") or filename.startswith("AlgoWeightHisto"))]
            
            #superlearner_plots = [" InvRedshiftDistribution fulldataset.png"]

            for i, plot_file in enumerate(superlearner_plots):

                if os.path.exists(plot_file):
                    image = Image.open(plot_file)
                    st.image(image)

        elif use_m_estimator == "Yes" and use_mice == "Yes" and apply_smote == "Yes":
            plot_dir = "CURRENT_ANALYSIS/Graphics/XRAY/BALANCING/MICE_WITH_M-estimator"
            temp_input_file = "training_data.csv"
            with open(temp_input_file, "wb") as f:
                f.write(uploaded_file.getbuffer())
            # Example usage
            convert_rmd_to_r('M-estimator_XRAY_ON_RAW_DATA.Rmd','M-estimator_XRAY_ON_RAW_DATA.R')
            run_r_script("M-estimator_XRAY_ON_RAW_DATA.R",temp_input_file,wcutoff = weight_cutoff)
            convert_rmd_to_r("MICE-Imputation_RAW-with_M-estimator.Rmd","MICE-Imputation_RAW-with_M-estimator.R")
            run_r_script("MICE-Imputation_RAW-with_M-estimator.R",temp_input_file)
            convert_rmd_to_r("balancing_ubSMOTE_XRAY_MICE.Rmd","balancing_ubSMOTE_XRAY_MICE.R")
            run_r_script("balancing_ubSMOTE_XRAY_MICE.R")
            convert_rmd_to_r('data-XRAY-Classification_ON_ubBALANCE-MICE-RAW_WITH-M-estimator.Rmd', 'data-XRAY-Classification_ON_ubBALANCE-MICE-RAW_WITH-M-estimator.R')
            run_r_script('data-XRAY-Classification_ON_ubBALANCE-MICE-RAW_WITH-M-estimator.R',cutoff = redshift_cutoff)

            superlearner_plots = [os.path.join(plot_dir, filename) for filename in os.listdir(plot_dir) 
                      if filename.endswith(".png") 
                      and not (filename.startswith("AlgoRiskHisto") or filename.startswith("AlgoWeightHisto"))]
            
            #superlearner_plots = [" InvRedshiftDistribution fulldataset.png"]

            for i, plot_file in enumerate(superlearner_plots):

                if os.path.exists(plot_file):
                    image = Image.open(plot_file)
                    st.image(image)
