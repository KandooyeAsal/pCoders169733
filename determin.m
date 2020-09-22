function det22 = determin(mat1,mat2)
Mat = [mat1 ;mat2];
det22 = Mat(1,:).*Mat(4,:) - Mat(2,:).*Mat(3,:);
end

