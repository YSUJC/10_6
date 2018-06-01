function drawopt = drawtrackresult(drawopt, fno, frame, s, c)
%% function drawopt = drawtrackresult(drawopt, fno, frame, s, c)
%%
%% Call this function to draw results

if (isempty(drawopt))      
  figure('position',[50 50 size(frame,2) size(frame,1)]); clf;                               
  set(gcf,'DoubleBuffer','on', 'MenuBar','none');
  colormap('gray');

  drawopt.curaxis = [];
  drawopt.curaxis.frm  = axes('position', [0.00 0 1.00 1.0]);
end

curaxis = drawopt.curaxis;
axes(curaxis.frm);      
imagesc(frame, [0,1]); 
hold on;     

a = [c(2)-s(2)/2 c(2)-s(2)/2 c(2)+s(2)/2 c(2)+s(2)/2 c(2)-s(2)/2];
b = [c(1)-s(1)/2 c(1)+s(1)/2 c(1)+s(1)/2 c(1)-s(1)/2 c(1)-s(1)/2];
line(a, b, 'Color','w', 'LineWidth',3); 

text(5, 15, ['#' num2str(fno)], 'Color','y', 'FontWeight','bold', 'FontSize',20);

axis equal off;
hold off;
drawnow;   