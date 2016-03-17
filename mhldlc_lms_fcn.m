desired_output=randn(1,500);%normrnd(2,4,[1,500]);%mean=2,sigma=4
% subplot(4,1,1);
% plot(1:500,desired_output);
% title('Channel equalization');
% legend('Actual Input');
% xlabel('Time index');ylabel('Signal value');
desired_output=[zeros(1,order-1),desired_output(1:end)];%appending zeros
channel=fir1(3,0.5);
noise=0.1*randn(1,500+order-1);
input_lms=filter(channel,1,desired_output)+noise;
step_size=0.08;
reset_weights = zeros(1,500+order-1);
mse_order=zeros(1,16);
mse_step=zeros(1,16);
%size(desired_output)
for order=1:1:16 %6 seem to be the optimal filter
desired_output=randn(1,500);
desired_output=[zeros(1,order-1),desired_output(1:end)];%appending zeros
channel=fir1(3,0.5);
noise=0.1*randn(1,500+order-1);
input_lms=filter(channel,1,desired_output)+noise;
step_size=0.08;
reset_weights = zeros(1,500+order-1);
[filtered_signal, y, fc] = lmsAlgoCode1(input_lms, desired_output, step_size, reset_weights,order);%y is the error
%y:1X6, fc:1X6
mse_order(order)=sqrt(mean(y.*y));
% disp('Mean sqaured error for filter order')
% order
% disp(' is ')
% disp(mse(order));
end

order=6;
%Study wrt step size
for step_size=0.01:0.01:0.16%0.07 seems to be optimal
desired_output=randn(1,500);
desired_output=[zeros(1,order-1),desired_output(1:end)];%appending zeros
channel=fir1(3,0.5);
noise=0.1*randn(1,500+order-1);
input_lms=filter(channel,1,desired_output)+noise;
reset_weights = zeros(1,500+order-1);
[filtered_signal, y, fc] = lmsAlgoCode1(input_lms, desired_output, step_size, reset_weights,order);%y is the error
%y:1X6, fc:1X6
mse_step(int8(step_size*100))=sqrt(mean(y.*y)); 
end





% subplot(4,1,2);
% plot(1:500+order-1,desired_output);
% legend('Desired/Input');
% subplot(4,1,3);
% plot(1:order,fc);
% legend('Filter coefficients');
% subplot(4,1,4);
% plot(1:500,filtered_signal);%filtered signal is a constant value? why?
% legend('Filtered signal');
