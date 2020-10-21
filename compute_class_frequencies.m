DATASET_FOLDER = '../MSRC_ObjCategImageDatabase_v2';
allfiles=dir(fullfile([DATASET_FOLDER,'/Images/*.bmp']));

class_freq = zeros(1, 20);

fout=['class_frequency.mat'];
for filenum=1:length(allfiles)
    fname=allfiles(filenum).name;
    name_split = split(fname, '_');
    lname = name_split(1);
%     i = str2num(['uint8(',lname{1},')']);
    i = str2num(lname{1});
    class_freq(i) = class_freq(i) + 1;
end

class_freq
save(fout, 'class_freq');