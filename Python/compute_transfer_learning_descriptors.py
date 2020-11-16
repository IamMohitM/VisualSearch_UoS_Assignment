import os
import argparse
import numpy as np
import cv2 as cv
import scipy.io

preprocess = None;

def extract_features(images, model, output_path=None, resize_shape=(224, 224)):
    image_features = []
    for im in images:
        img = cv.imread(im)
        img = cv.resize(img, resize_shape)
        img = np.expand_dims(img, axis=0)
        img = preprocess(img)
        features = model.predict(img).flatten()
        if output_path:
            filename=os.path.join(output_path, os.path.basename(im).split('.')[0])+'.mat'
            scipy.io.savemat(filename, {'F': features})
            print(f"saving to {filename}")
        image_features.append(features)
    return image_features

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process inputs')
    parser.add_argument('-D', '--dataset_path', help='path to dataset',
                        default=r"../MSRC_ObjCategImageDatabase_v2/Images/")
    parser.add_argument('output_path', metavar='o', type=str,
                        help ="Folder to save descriptors")
    parser.add_argument('model', metavar='m', type=str,
                        help ="Model Name - vgg19/resnet50/resnet152")
    args = parser.parse_args()

    dataset_path = args.dataset_path
    images = [os.path.join(dataset_path, file) for file in os.listdir(dataset_path) if file.endswith('.bmp')]

    model_name = args.model
    output_path = args.output_path

    if model_name.lower()=="vgg19":
        print("Loading VGG19")
        from keras.applications import VGG19
        from keras.applications.vgg19 import preprocess_input
        model = VGG19(include_top=False, weights="imagenet")
    elif model_name.lower()=="resnet50":
        print("Loading Resnet 50")
        from keras.applications import ResNet50
        from keras.applications.resnet import preprocess_input
        model = ResNet50(include_top=False, weights="imagenet")
    elif model_name.lower() == "resnet152":
        print("Loading Resnet 152")
        from keras.applications import ResNet152
        from keras.applications.resnet import preprocess_input
        model = ResNet152(include_top=False, weights="imagenet")
    else:
        print("Incorrect input Make sure the model names are 'vgg19' or 'resnet50' or 'resnet152'!\n.Exiting! ")
        exit()
    preprocess = preprocess_input
    extract_features(images, model, output_path)
