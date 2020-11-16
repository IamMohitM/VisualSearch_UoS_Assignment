## VisualSearch Assignment

### Project Structure

- MATLAB Scripts<br>
- Python (Directory)<br>
  scripts for SIFT, transfer learning and SVM classification
- cwork_basecode_2012 (Directory)<br>
 basecode provided and improvised<br>
- descriptors(Directory needs to be created by user)
- Results(Directory needs to be created by user)

### Setting up your project

1. Create a descriptors folder
2. Create a Results folder
3. Make sure the MSRC_ObjCategImageDatabase_v2 is in the top project-level folder or where the README.md file exists
4. Add cwork_basecode_2012 folder to MATLAB path

SIFT Descriptors-Bag of Visual Words, Transfer Learning and SVM Classification was computed in Python.

1. Install Python 3.6=<
2. Install opencv-Python
3. Install Keras
4. Install sklearn
5. Install Scipy
6. install argparse

### Compute Global Color Histogram

1. Create a folder (colorHisto_4) inside descriptors folder
2.  Run the following command

```computeGlobalColorHistDescriptors("RGBHISTO_4", 4);```

The above command will create .mat descriptors inside colorHisto_4 folder with quantization 4

### ComputeGridTextureDescriptors

1. Create TD_25_30 folder in descriptors folder
2. Run the following command

```computeGridTextureDescriptors("TD_25_30", 25, 20);```

This computes texture descriptors with grid size 25 and 20 edge orientation ranges

### Compute Principal Components

1. Create PCA_TD_25_30 folder in descriptors folder
2. Run the following command

```computePCA("TD_25_30", "PCA_TD_25_30", 20);```

This will compute the top 20 principal components of your features dimensions and save the descriptors in PCA_TD_25_30 folder. It will also save the projection matrix in PCA_TD_25_30 folder.

To compute components that contribute 97% of the variance

```computePCA("TD_25_30", "PCA_TD_25_30", 0.97, true);```

### Perform VisualSearch

```[p, r, ap] = cvpr_visualsearch("colorHisto_4", "cosine" );```

To perform visual search on class 4 and return top 20 Results

```[p, r, ap] = cvpr_visualsearch("colorHisto_4", "Euclidean", 20, 4);```


Perform Visual Search with Mahalanobis (Only for PCA descriptors which have `projectionMatrix.mat` in their DESCRIPTOR_SUBFOLDER)

```[p, r, ap] = cvpr_visualsearch("PCA_TD_25_30", "Mahalanobis", 20, 4);```

### SIFT and BOVW

To compute the SIFT Descriptors followed by computing Bag of Visual Words (BOVW) use `compute_sift_bovw_Descriptors` in the Python Folder

Syntax:

```python compute_sift_bovw_Descriptors.py "path to dataset"(optional) output_path(mandatory) k-clusters(mandatory)```

default dataset_path is the top-level project folder or where README.md file is. (../MSRC_ObjCategImageDatabase_v2/Images/)

Example:

Create a SIFT_BOVW folder inside descriptors folder

```python compute_sift_bovw_Descriptors.py "..descriptors/SIFT_BOVW" 100```

Will compute BOVW with 100 n_clusters and save the features in SIFT_BOVW folder

If your dataset is in a different path, for example in home directory, use:

```python compute_sift_bovw_Descriptors.py --dataset_path "~/MSRC_ObjCategImageDatabase_v2/Images/" "..descriptors/SIFT_BOVW" 100" 100```


### Transfer Learning

To compute the transfer learning descriptors with vgg19, resnet50or  resnet152 use `compute_transfer_learning_descriptors.py` in the Python Folder

Syntax:

```python compute_transfer_learning_descriptors.py --dataset_path "path to dataset"(optional) output_path(mandatory) model_name(mandatory)```

model_name values: ["vgg19", "resnet50", "resnet152"]
default dataset_path is the top-level project folder or where README.md file is. (../MSRC_ObjCategImageDatabase_v2/Images/)

Example:
Computing vgg19 descriptors

Create a VGG19 folder inside descriptors folder

```python compute_transfer_learning_descriptors.py "..descriptors/VGG19" "vgg19"```

Will compute features using pre-trained VGG19 model and save the features in VGG19 folder

If your dataset is in a different path, for example in home directory, use:

```python compute_transfer_learning_descriptors.py --dataset_path "~/MSRC_ObjCategImageDatabase_v2/Images/" "..descriptors/ResNet_50" "resnet50"```

### Testing your Descriptors

#### Defaults
Distance Metrics- ["Euclidean", "Cosine", "Manhattan"]
points = [3, 5, 10, 15, 20]

Use:

```calculate_test_results(DESCRIPTOR_SUBFOLDER, [3, 5])```

This will calculate Average precision per class and Mean Average precision for top 3 and top 5 results with cosine, Euclidean and Manhattan Distance. The Average Precision per class is calculated by querying randomly for that class and averaging the 10 average precisions. This will create a Results.xlsx in the Results and 3 sheets one for each distance type

```calculate_test_results(descriptors/TF_25_30);```



To calculate with Mahalanobis Distance (make sure there is a projectionMatrix.mat file in your DESCRIPTOR_SUBFOLDER)

```calculate_test_results("DESCRIPTOR_SUBFOLDER", [3, 5] ,true)```

### SVM Classification

#### Syntax

```python svm_training.py "path to features"(mandatory) --kernel (optional) --gamma (optional) --test_size (optional)```

This will also print the Accuracy, Classification report with precision and recall per class and mean average precision and plot a confusion matrix

#### Default Values

kernel - 'sigmoid'<br>
gamma - 0.00001<br>
test_size - 0.15<br>

More information about kernels and gamma at https://scikit-learn.org/stable/modules/generated/sklearn.svm.SVC.html

Example:
Training with vgg19 descriptors

```python svm_training.py "../descriptors/vgg19/" --kernel "sigmoid" --gamma 0.000001```

Training with a different test size

```python svm_training.py "../descriptors/vgg19/" --test_size 0.2```


#### Best parameters for VGG19
kernel - 'sigmoid'<br>
gamma - 0.000001<br>

#### Best Parameters for ResNet_50
kernel - 'sigmoid'<br>
gamma - 0.00001<br>
