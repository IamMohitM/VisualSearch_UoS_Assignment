import os
import cv2
import scipy.io
import argparse
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Compute BOVW of k cluster of SIFT Descriptors ')
    parser.add_argument('--dataset_path', help='path to dataset',
                        default=r"../MSRC_ObjCategImageDatabase_v2/Images/")
    parser.add_argument('output_path', metavar='o', type=str,
                        help ="Folder to save descriptors")
    parser.add_argument('n_clusters', metavar='k', type=int,
                        help ="Number of clusters", default=5)
    args = parser.parse_args()

    dataset_path = args.dataset_path
    print(f"Data set Path - {dataset_path}")
    images = [os.path.join(dataset_path, file) for file in os.listdir(dataset_path)
                if file.endswith('.bmp')]

    print(f"Total Images {len(images)}")
    print("Computing SIFT Descriptors")
    descriptors = [];
    for im in images:
        img = cv2.imread(im, 0)
        sift = cv2.SIFT_create()
        kp, des = sift.detectAndCompute(img,None)
        for descriptor in des:
            descriptors.append(descriptor) #can use extend

    descriptors = np.array(descriptors)

    n_clusters = args.n_clusters;
    scaler = StandardScaler()
    scaled_features = scaler.fit_transform(descriptors)
    print(f"Clustering the data into {n_clusters} clusters");
    kmeans = KMeans(n_clusters=n_clusters, random_state=0)
    model = kmeans.fit(scaled_features)

    output_path = args.output_path; #"../descriptors/test/"

# lazy programming :)
# It is okay to compute descriptors again because SIFT is a repeating descriptor
    for im in images:
        img = cv2.imread(im, 0)
        sift = cv2.SIFT_create()
        kp, des = sift.detectAndCompute(img,None)
        scaled_descriptor = scaler.transform(des)
        scaled_descriptor  = scaled_descriptor.astype(np.float32)
        image_clusters = model.predict(scaled_descriptor)
        frequency, _ = np.histogram(image_clusters, bins = n_clusters, range=(0, n_clusters-1))
        filename = os.path.join(output_path, os.path.basename(im).split('.')[0])+'.mat'
        scipy.io.savemat(filename, {'F': frequency})
        print(f"Saving to {filename}")
