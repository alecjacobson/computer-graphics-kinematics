function write_json(json_file,model_file,weights_file,P,WI,T,fk_animation)
  fp = fopen(json_file);
  fprintf(fp,'{\n');
  fprintf(fp,'}\n');
  fclose(fp);

end
