import os
import argparse
import scipy.io
import numpy as np
import matplotlib.pyplot as plt

from sklearn.svm import SVC
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from sklearn.metrics import plot_confusion_matrix

#Mapping classes to its catgories
class_dict = {1:'grass', 2: "trees", 3: "building", 4:"aeroplane", 5:"cow",
             6: "face", 7: "car", 8:"bike", 9: "sheep", 10:"flower", 11:"sign",
             12: "bird", 13: "books", 14: "chair", 15: "cat", 16: "dog",
             17:"road", 18: "water", 19: "body", 20: "water with sky"}

def extract_features_labels(features_path):
    """
        extract features from in .mat files in the "features_path"
    """
    files=[os.path.join(features_path, file) for file in os.listdir(features_path)]
    features= np.array([scipy.io.loadmat(file)['F'].flatten() for file in files if file.endswith(".mat")])
    labels = np.array([int(file.split('_')[0]) for file in os.listdir(features_path) if file.endswith(".mat")])
    return features, labels

#plots a confusion matrix
def plot_conf_matrix(classifier, X_test, y_test, class_labels):
    fig, ax = plt.subplots(figsize=(20, 20))
    titles_options = [("Normalized confusion matrix", 'true')]

    disp = plot_confusion_matrix(classifier, X_test, y_test,
                                 display_labels=class_labels,
                                 cmap=plt.cm.Blues,
                                 normalize="true", ax = ax)
    disp.ax_.set_title("Normalized confusion matrix")

    plt.show()


if __name__ == "__main__":

    parser = argparse.ArgumentParser(description='Train SVM with given features, display classification report and confusion matrix')
    parser.add_argument('features_path', metavar='P', help='path to feature folder')
    parser.add_argument('--gamma', metavar='g', type=float,
                        help ="Types of features - only Vgg19/resnet50",
                        default = 0.00001)
    parser.add_argument('--kernel', metavar='k', type=str,
                        help ="kernel type for SVM",
                        default = 'sigmoid')
    parser.add_argument('--test_size', metavar='t', type=float,
                        help ="Test Set Size",
                        default = 0.15)
    args = parser.parse_args()

    features_path = args.features_path
    features, labels = extract_features_labels(features_path)

    #Setting input arguments
    gamma = args.gamma
    kernel = args.kernel
    test_size = args.test_size


    X_train, X_test, y_train, y_test = train_test_split(features,labels, test_size=test_size)
    print('Training data and target sizes: \n{}, {}'.format(X_train.shape,y_train.shape))
    print('Test data and target sizes: \n{}, {}'.format(X_test.shape,y_test.shape))

    print("Training....")
    classifier = SVC(gamma=gamma, kernel=kernel,decision_function_shape='ovo')
    classifier.fit(X_train, y_train)
    print(f"Accuracy {np.mean(classifier.predict(X_test) == y_test)}")

    r = classification_report(y_test, classifier.predict(X_test))
    print(r)
    plot_conf_matrix(classifier, X_test, y_test, class_dict.values())
