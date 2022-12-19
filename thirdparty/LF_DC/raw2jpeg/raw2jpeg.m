function raw2jpeg(lfp_file)
cd('lfptools')                                                            ;
sys_command =  ['./lfpsplitter ../' lfp_file]                             ;
system(sys_command,'-echo')                                               ;
cd('..')                                                                  ;

[lfp_folder lfp_path b]   = fileparts(lfp_file)                           ;

lfp_path = [lfp_folder '/' lfp_path]                                      ;

fin = fopen(strcat(lfp_path, '_imageRef0.raw'), 'r')                      ;
meta = fopen(strcat(lfp_path, '_metadataRef0.txt'), 'r')                  ;

for i = 1:3
    fgets(meta)                                                           ;
end
fgets(meta, 12)                                                           ;
width = fscanf(meta, '%d')                                                ;
fgets(meta)                                                               ;
fgets(meta, 12)                                                           ;
height = fscanf(meta, '%d')                                               ;

I = fread(fin, width*height, 'uint16=>uint16')                            ;
im_in = reshape(I, height, width)                                         ;

im_in = im_in'                                                            ;

delete([lfp_path '_imageRef0.raw'], [lfp_path '_metadataRef0.txt'], ...
    [lfp_path '_privateMetadataRef1.txt'], [lfp_path '_table.txt'])       ;

im_in = im_in.*1.5                                                        ;
imwrite(im2uint8(im_in), strcat(lfp_path,'.jpg'))                         ;

end