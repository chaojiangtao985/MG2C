#!C:/Perl64/bin/perl
use strict;
use POSIX;

print "Content-type:text/html"."\n\n";
print "<HTML>"."\n";
print "<HEAD>"."\n";
print "<meta http-equiv=\"content-type\" content=\"text/html;charset=utf-8\">\n";
print "<TITLE>MapGene2Chrom</TITLE>"."\n";
print "</HEAD>"."\n";
print "<BODY>"."\n";
#print "<H2>I am do my best!</H2>"."\n";

my ($title_font_family,$title_font_size,$title_font_color);
my ($svg_width,$svg_height);
my ($svg_chrom_height,$svg_chrom_width,$svg_chrom_border_color,$svg_chrom_border_width,$svg_chrom_fill_color);
my ($chrom_init_len,$chrom_init_width);
my ($chrom_x,$chrom_y,$chrom_rx,$chrom_ry);
my ($chrom_fill_color,$chrom_border_color,$chrom_border_width);
my ($gene_line_type,$gene_line_color,$gene_line_width,$gene_name_font_color,$gene_name_font_family,$gene_name_font_size,$gene_name_margin);
my ($link_polyline_width,$link_polyline_color);
my ($geneName2chrom_margin);
my ($scale_len,$scale_chrom_margin_y,$scale_y,$scale_unit,$scale_unit_float);

my (@NameAndValuelists,$NameAndValue,$Name,$Value,$aatemp,@paras);
my ($gggene_info,$ccchrom_info);


#读取参数值，存入@paras数组中备用。
#my $QuerystringFromEnv=$ENV{QUERY_STRING};
my $QuerystringFromEnv;
if($ENV{"REQUEST_METHOD"} eq "GET"){ 
  $QuerystringFromEnv=$ENV{"QUERY_STRING"}; 
}elsif($ENV{"REQUEST_METHOD"} eq "POST"){ 
	#print "2222222222";
	read(STDIN,$QuerystringFromEnv,$ENV{"CONTENT_LENGTH"}); 
}

@NameAndValuelists=split(/&/,$QuerystringFromEnv);
foreach $NameAndValue(@NameAndValuelists){
    ($Name,$Value)=split(/=/,$NameAndValue);
    $Name=~tr/+//;
    $Value=~s/%([\dA-Fa-f][\dA-Fa-f])/pack("c",hex($1))/eg;
    $aatemp="$Name\=$Value";
    push @paras,$aatemp;
    if($Name eq "gene_info"){$gggene_info=$Value;}
    if($Name eq "chrom_info"){$ccchrom_info=$Value;}
}
#获取各个参数的值
#$gggene_info=getParaValue("gene_info");
#$ccchrom_info=getParaValue("chrom_info");

$svg_width=getParaValue("svg_width");
$svg_height=getParaValue("svg_height");
$svg_chrom_height=getParaValue("svg_chrom_height");
$svg_chrom_width=getParaValue("svg_chrom_width");
$svg_chrom_border_color=getParaValue("svg_chrom_border_color");
$svg_chrom_border_width=getParaValue("svg_chrom_border_width");
$svg_chrom_fill_color=getParaValue("svg_chrom_fill_color");

$title_font_family=getParaValue("title_font_family");
$title_font_size=getParaValue("title_font_size");
$title_font_color=getParaValue("title_font_color");

$chrom_init_len=getParaValue("chrom_init_len");
$chrom_init_width=getParaValue("chrom_init_width");
$chrom_rx=getParaValue("chrom_rx");
$chrom_ry=getParaValue("chrom_ry");
$chrom_fill_color=getParaValue("chrom_fill_color");
$chrom_border_color=getParaValue("chrom_border_color");
$chrom_border_width=getParaValue("chrom_border_width");

$gene_line_type=getParaValue("gene_line_type");
$gene_line_color=getParaValue("gene_line_color");
$gene_line_width=getParaValue("gene_line_width");
$gene_name_font_color=getParaValue("gene_name_font_color");
$gene_name_font_family=getParaValue("gene_name_font_family");
$gene_name_font_size=getParaValue("gene_name_font_size");
$gene_name_margin=$gene_name_font_size;
$geneName2chrom_margin=getParaValue("geneName2chrom_margin");

$link_polyline_color=getParaValue("link_polyline_color");
$link_polyline_width=getParaValue("link_polyline_width");

$scale_len=getParaValue("scale_len");
$scale_chrom_margin_y=getParaValue("scale_chrom_margin_y");
$scale_y=getParaValue("scale_y");
$scale_unit=getParaValue("scale_unit");
$scale_unit_float=getParaValue("scale_unit_float");


my(@allGenes,%geneGroup,@group,$i,$rows,$columns,$chrom_num,$r,$c,$xn);

my ($svg_info,$j);

@allGenes=split(/\n/,$gggene_info);

@allGenes=cleanArray(@allGenes);
%geneGroup=splitGeneInfoByChrom(@allGenes);

my@aaa=keys %geneGroup;
my ($geneMaxNum,$diff_len);
$geneMaxNum=getMaxGeneNum();


if($gene_name_margin*$geneMaxNum/2>$chrom_init_len){
	$diff_len=int(($gene_name_margin*$geneMaxNum/2)/10)*10-$chrom_init_len;
	$chrom_init_len=int(($gene_name_margin*$geneMaxNum/2)/10)*10;
	$svg_chrom_height=$svg_chrom_height+$diff_len;
}
#读取染色体信息，包括染色体名称和长度ƍ
my @chroms=split(/\n/,$ccchrom_info);

@chroms=cleanArray(@chroms);
my $maxChromUnit=getMaxChromUnit();

$chrom_num=$#chroms+1;	#计算显示的染色体个数
$columns=int($svg_width/$svg_chrom_width);	#计算一行显示几条染色体？
$rows=ceil($chrom_num/$columns);	#计算共显示几行染色体。

#依据输入文件中有几个scaffold，智能调整svg整体尺寸的大小。
$svg_width=$columns*$svg_chrom_width;
$svg_height=$rows*$svg_chrom_height;

#输出SVG图形的开头部分
$svg_info="<?xml version=\"1.0\" standalone=\"no\"?>\n";
$svg_info.="<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n";
$svg_info.="<svg width=\"$svg_width\" height=\"$svg_height\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n";
  
#r代表rows 第r行，从0开始计数；c代表columns 第c列，从0开始计数。
$r=0;$c=0;
for($i=0;$i<=$#chroms;$i++){
	my ($ch_name,$ch_len)=split(/\s+/,$chroms[$i]);
	$xn=$i+1;
	@group=split(/\n/,$geneGroup{$ch_name});
	@group=sortGenesAscByStart(@group);
	
	my ($geneNameMax,$chrom_bps,$chrom_len,@temp,$chrom_rect_x,$chrom_rect_y);
	my ($chrom_name_x,$chrom_name_y,$chrom_name);	
	
	$geneNameMax=getMaxlenGeneName(@group);
	@temp=split(/\s+/,$group[0],5);
	if($temp[4] eq ""){
		$chrom_bps=$ch_len;
	}else{
		$chrom_bps=$temp[4];
	}
	$chrom_name=$temp[3];
	$chrom_len=($chrom_bps/$maxChromUnit)*10;
	$chrom_len=ceil($chrom_len)/10;
	$chrom_x=$svg_chrom_width/2-$chrom_init_width/2+$c*$svg_chrom_width;
	$chrom_y=20+$title_font_size*2.5+$r*$svg_chrom_height;
	
	#计算染色体标题应该显示的位置。
	$chrom_name_x=$svg_chrom_width/2+$c*$svg_chrom_width;
	$chrom_name_y=$chrom_y-$title_font_size;	
	
	#绘制染色体边框的左上角坐标。
	$chrom_rect_x=0+$c*$svg_chrom_width;
	$chrom_rect_y=0+$r*$svg_chrom_height;
	
	#输出染色体区域边框线
	$svg_info.="<rect  width=\"$svg_chrom_width\" height=\"$svg_chrom_height\" x=\"$chrom_rect_x\" y=\"$chrom_rect_y\" style=\"stroke-width:$svg_chrom_border_width;stroke:$svg_chrom_border_color; fill:$svg_chrom_fill_color;\"/>\n";
	#输出染色体名称
	$svg_info.="<text x=\"$chrom_name_x\" y=\"$chrom_name_y\" text-anchor=\"middle\" font-family=\"$title_font_family\" font-size=\"$title_font_size\" fill=\"$title_font_color\" >$chrom_name</text>\n";
  #输出染色体
  $svg_info.="<rect  width=\"$chrom_init_width\" height=\"$chrom_len\" x=\"$chrom_x\" y=\"$chrom_y\" rx=\"$chrom_rx\" ry=\"$chrom_ry\" style=\"stroke-width:$chrom_border_width;stroke:$chrom_border_color;fill:$chrom_fill_color;\"/>\n";     
	
	#print "$title_font_size\n";
	
	my ($text_x,$text_y);
	my ($Rprev_y,$text_top_margin,$temp_y_margin);
	my($poly_x1,$poly_x2,$poly_x3,$poly_x4);
  my($poly_y1,$poly_y2,$poly_y3,$poly_y4);
  
  #画将偶数基因画在染色体的左边
	for($j=0;$j<=$#group;$j=$j+2){
		 my ($gname,$gstart,$gend,$chromID,$chromLen)=split(/\s+/,$group[$j],5);
		 
		 my ($gene_x1,$gene_x2,$gene_y1,$gene_y2,$gene_x,$gene_y);
		 $gene_x1=$chrom_x;
     $gene_x2=$chrom_x+$chrom_init_width;
     $gene_y1=$chrom_y+$gstart/$maxChromUnit;
     $gene_y2=$chrom_y+$gend/$maxChromUnit;
     my $gene_height=($gend-$gstart)/$maxChromUnit;
       
     $gene_y=($gene_y1+$gene_y2)/2;
     $gene_y=sprintf("%.0f",$gene_y);
     
     if($gene_line_type==1){
		 	$svg_info.="<line x1=\"$gene_x1\" y1=\"$gene_y\" x2=\"$gene_x2\" y2=\"$gene_y\" style=\"stroke:$gene_line_color;stroke-width:$gene_line_width\"/>\n";
		 }
		 if($gene_line_type==2){
		 	$svg_info.="<rect  width=\"$chrom_init_width\" height=\"$gene_height\" x=\"$gene_x1\" y=\"$gene_y1\" style=\"stroke-width:$gene_line_width;stroke:$gene_line_color;fill:$gene_line_color;\"/>\n";     
		 }
		  
		 if($j==0){$Rprev_y=$gene_y;}      
     
     $text_x=$gene_x1-$geneName2chrom_margin-1;     
     
     #计算基因连接线的坐标
     $poly_x1=$gene_x1;
     $poly_y1=$gene_y;
     
     $poly_x2=$gene_x1-$geneName2chrom_margin*0.3;
     $poly_y2=$gene_y;
     
     $poly_x3=$gene_x1-$geneName2chrom_margin*0.7;     
     $poly_x4=$gene_x1-$geneName2chrom_margin*1.0;
     
     my $g_num=$#group;
     if($g_num*$gene_name_margin/2 >= $chrom_init_len*0.9){     
       	$temp_y_margin=$gene_name_margin*0.5;
       	$text_y=$Rprev_y+$temp_y_margin+$gene_name_font_size*0.4;
       	$poly_y3=$Rprev_y+$temp_y_margin;
       	$poly_y4=$Rprev_y+$temp_y_margin;
   	 }else{
     		 if( $gene_y-$Rprev_y>=$gene_name_margin){
       		$text_y=$gene_y+$gene_name_font_size*0.4;
       		$poly_y3=$gene_y;
       		$poly_y4=$gene_y;       		
       	 }else{
       		$temp_y_margin=$gene_name_margin*0.5;
       		$text_y=$Rprev_y+$temp_y_margin+$gene_name_font_size*0.4;
       		$poly_y3=$Rprev_y+$temp_y_margin;
       		$poly_y4=$Rprev_y+$temp_y_margin;
       	 }
   	 }
     #输出基因线与基因名称的连接线；基因名称
     $svg_info.="<polyline points=\"$poly_x1,$poly_y1 $poly_x2,$poly_y2 $poly_x3,$poly_y3 $poly_x4,$poly_y4\" style=\"fill:none;stroke:$link_polyline_color;stroke-width:$link_polyline_width\"/>\n";
     $svg_info.="<text x=\"$text_x\" y=\"$text_y\" text-anchor=\"end\" font-family=\"$gene_name_font_family\" font-size=\"$gene_name_font_size\"  fill=\"$gene_name_font_color\">$gname</text>\n";
     
     $Rprev_y=$text_y;		
	}
	
	#画将奇数基因画在染色体的右边
	for($j=1;$j<=$#group;$j=$j+2){
		 my ($gname,$gstart,$gend,$chromID,$chromLen)=split(/\s+/,$group[$j],5);
		 
		 my ($gene_x1,$gene_x2,$gene_y1,$gene_y2,$gene_x,$gene_y);
		 $gene_x1=$chrom_x;
     $gene_x2=$chrom_x+$chrom_init_width;
     $gene_y1=$chrom_y+$gstart/$maxChromUnit;
     $gene_y2=$chrom_y+$gend/$maxChromUnit;
       
     $gene_y=($gene_y1+$gene_y2)/2;
     $gene_y=sprintf("%.0f",$gene_y);
     
     my $gene_height=($gend-$gstart)/$maxChromUnit;
     if($gene_line_type==1){
		 	$svg_info.="<line x1=\"$gene_x1\" y1=\"$gene_y\" x2=\"$gene_x2\" y2=\"$gene_y\" style=\"stroke:$gene_line_color;stroke-width:$gene_line_width\"/>\n";
		 }
		 if($gene_line_type==2){
		 	$svg_info.="<rect  width=\"$chrom_init_width\" height=\"$gene_height\" x=\"$gene_x1\" y=\"$gene_y1\" style=\"stroke-width:$gene_line_width;stroke:$gene_line_color;fill:$gene_line_color;\"/>\n";     
		 }
		 
		 if($j==1){$Rprev_y=$gene_y;}      
     
     $text_x=$gene_x2+$geneName2chrom_margin+1;  
     
     #计算基因连接线的坐标
     $poly_x1=$gene_x2;
     $poly_y1=$gene_y;
     
     $poly_x2=$gene_x2+$geneName2chrom_margin*0.3;
     $poly_y2=$gene_y;
     
     $poly_x3=$gene_x2+$geneName2chrom_margin*0.7; 
     $poly_x4=$gene_x2+$geneName2chrom_margin*1.0;
     
     my $g_num=$#group;
     if($g_num*$gene_name_margin/2 >= $chrom_init_len*0.9){
       $temp_y_margin=$gene_name_margin*0.5;
       $text_y=$Rprev_y+$temp_y_margin+$gene_name_font_size*0.4;
       $poly_y3=$Rprev_y+$temp_y_margin;
       $poly_y4=$Rprev_y+$temp_y_margin;
     }else{
     	if( $gene_y-$Rprev_y>=$gene_name_margin){
       		$text_y=$gene_y+$gene_name_font_size*0.4;
       		$poly_y3=$gene_y;
       		$poly_y4=$gene_y;       		
       }else{
       		$temp_y_margin=$gene_name_margin*0.5;
       		$text_y=$Rprev_y+$temp_y_margin+$gene_name_font_size*0.4;
       		$poly_y3=$Rprev_y+$temp_y_margin;
       		$poly_y4=$Rprev_y+$temp_y_margin;
       }     	
    }
    #输出基因线与基因名称的连接线；基因名称
    $svg_info.="<polyline points=\"$poly_x1,$poly_y1 $poly_x2,$poly_y2 $poly_x3,$poly_y3 $poly_x4,$poly_y4\" style=\"fill:none;stroke:$link_polyline_color;stroke-width:$link_polyline_width\"/>\n";
    $svg_info.="<text x=\"$text_x\" y=\"$text_y\" text-anchor=\"start\" font-family=\"$gene_name_font_family\" font-size=\"$gene_name_font_size\"  fill=\"$gene_name_font_color\">$gname</text>\n";
     
    $Rprev_y=$text_y;	

	}
	#在图上画上刻度尺
 	my($sx1,$sx2,$sy1,$sy2);
	my($stx,$sty,$stext,$st_num);
	
	#计算刻度尺应所处的位置
	$sx1=$svg_chrom_width/2-$scale_len/2+$c*$svg_chrom_width;
	$sy1=$chrom_y+$chrom_len+$scale_chrom_margin_y;
	
	$sx2=$svg_chrom_width/2+$scale_len/2+$c*$svg_chrom_width;
	$sy2=$sy1;
	
	$stx=($sx1+$sx2)/2;
	$sty=$sy2-$gene_name_font_size*0.4;
	
	##分析刻度尺的尺寸是base pair=bp,还是里摩cM？
	if($scale_unit eq "bp"){
		$st_num=$maxChromUnit*$scale_len/1000;
		$stext="$st_num Kb";
		$svg_info.="<line x1=\"$sx1\" y1=\"$sy1\" x2=\"$sx2\" y2=\"$sy2\" style=\"stroke:$gene_line_color;stroke-width:$gene_line_width\"/>\n";
		$svg_info.="<text x=\"$stx\" y=\"$sty\" text-anchor=\"middle\" font-family=\"$gene_name_font_family\" font-size=\"$gene_name_font_size\"  fill=\"$gene_name_font_color\">$stext</text>\n";
	}elsif($scale_unit eq "cM"){
		$st_num=$maxChromUnit*$scale_len;
		$stext="$st_num $scale_unit";
		$svg_info.="<line x1=\"$sx1\" y1=\"$sy1\" x2=\"$sx2\" y2=\"$sy2\" style=\"stroke:$gene_line_color;stroke-width:$gene_line_width\"/>\n";
		$svg_info.="<text x=\"$stx\" y=\"$sty\" text-anchor=\"middle\" font-family=\"$gene_name_font_family\" font-size=\"$gene_name_font_size\"  fill=\"$gene_name_font_color\">$stext</text>\n";
	}else{
			print "参数 scale_unit 出错了！ 其值为\"bp\"或\"cM\";请注意检查<br>";
			exit(0);
	}	
	
	if(($i+1)%$columns==0){$r++;$c=0;}
	else{$c++;}	
}

$svg_info.='</svg>';

print "<br>".$svg_info."<br>";

my $hdir1="mg2c_v1.0";
my $hdir2="temp";
my $file=time()."_".int(rand(1000)).".svg";
my $output="$hdir1/$hdir2/$file";
open(OUT,">$output");
print OUT $svg_info;
close OUT;

my $output="$hdir2/$file";
print "Success! download the svg file by right click <a href='$output' style='text-decoration:none;'> here </a> by FirFox or IE9+<br>";

print "</BODY>"."\n";
print "</HTML>"."\n";


#获取指定染色体名称的序列长度
sub getChromLen{
	my ($chrom)=@_;
	
	my $chrom_len;
	
	$chrom_len=0;
	foreach my $line(@chroms){
		$line=~s/\n//g;
		my ($cname,$clen)=split(/\s+/,$line);
		if($chrom eq $cname){
			$chrom_len=int($clen);
		}
	}
	$chrom_len;
}

#将基因信息，按其开始位置升序排列
sub sortGenesAscByStart{
   my @array=@_;
   my($i,$j,$itemp,$jtemp,%genes,$key);
   my ($gname,$gstart,$gend,$chromID,$chromLen);
   
   for($i=0;$i<=$#array;$i++){
       ($gname,$gstart,$gend,$chromID,$chromLen)=split(/\s+/,$array[$i],5);
       $genes{$gstart}=$array[$i];
   }
   
   my @nArray;
   foreach $key(sort {$a <=> $b} keys %genes){
      push @nArray,$genes{$key};
   }
   #print "array=$#array; nArray=$#nArray<br>";
   @nArray;
}

#获取基因名称最长的字符数。
sub getMaxlenGeneName{
	my @array=@_;
	my ($gname,$gstart,$gend,$chromID,$chromLen);
	my ($i);
	
	my $maxLenGeneName=0;
	for($i=0;$i<$#array;$i++){
     ($gname,$gstart,$gend,$chromID,$chromLen)=split(/\s+/,$array[$i],5);
     if(length($gname)>$maxLenGeneName){
     	$maxLenGeneName=length($gname);  	
     }
  }
  $maxLenGeneName;
}

#获取单个染色体含有基因数量的最大值
sub getMaxGeneNum{
	my ($line);
	my ($maxGeneNum,$num);
	
	$maxGeneNum=0;
	foreach $line(keys %geneGroup){
		@group=split(/\n/,$geneGroup{$line});
		
		$num=$#group+1;		
		if($maxGeneNum<$num){
			$maxGeneNum=$num;
		}
	}
	
	$maxGeneNum;
}

#获取染色体单位长度的最大值
sub getMaxChromUnit{
	
	my ($maxChromUnit,$unit,$line,$chromLen);	
	$maxChromUnit=0;
	
	foreach $line(keys %geneGroup){
		$chromLen=getChromLen($line);
		if($chromLen<1){
			#print "$line chromLen must be more than 1<br>";			
		}else{
			$unit=$chromLen/$chrom_init_len;
			$unit=sprintf("%.$scale_unit_float"."f",$unit);	
			#print "$line=$unit 2222<br>";			
		}
		
		if($scale_unit eq "bp"){
			if($unit>=1000){
				$unit=(ceil($unit/1000))*1000;
			}
			
		}elsif($scale_unit eq "cM"){
			$unit=sprintf("%.$scale_unit_float"."f",$unit);
		}else{
			print "标尺单位只可为bp或cM值，其他方式暂时不支持。<br>";			
		}
		
		if($maxChromUnit<$unit){
			$maxChromUnit=$unit;
		}
	}
	
	#print "maxChromUnit=$maxChromUnit<br>";	
	$maxChromUnit;
}

#依据染色体名称，将基因信息进行分组。
sub splitGeneInfoByChrom{
	my @allGenes=@_;
	
	my (%geneGroup,$line);
	my ($gname,$gstart,$gend,$chromID,$chromLen);
	
	foreach $line(@allGenes){
		$line=~s/\n//g;
		($gname,$gstart,$gend,$chromID,$chromLen)=split(/\s+/,$line);
		$geneGroup{$chromID}.=$line."\n";		
	}
	%geneGroup;	
}

#读取含有基因位置信息的文件
sub readInput{
	my ($input)=@_;
	
	my (@array,@nArray);
	$/="\n";
	open(IN, "$input") or die("Can't open gene_info file $input, please check!\n");
	@array=<IN>;
	close IN;
	
	foreach my $line(@array){
		$line=~s/\n//g;
		
		if($line eq ""){
			
		}elsif($line=~/^\#/){
		}else{
			my @temp=split(/\s+/,$line);
			my $n=$#temp+1;
			if($n>=4){
				push @nArray,$line;
			}else{
			}
		}
	}
	
	@nArray;
}

#读取染色体信息文件
sub readChroms{
	my ($input)=@_;
	
	my (@array,@nArray);
	$/="\n";
	open(IN, "$input") or die("Can't open chrom file $input, please check!\n");
	@array=<IN>;
	close IN;
	
	foreach my $line(@array){
		$line=~s/\n//g;
		
		if($line eq ""){
			
		}elsif($line=~/^\#/){
			#print "עˍѐ£º$line--\n";
		}else{
			my @temp=split(/\s+/,$line);
			my $n=$#temp+1;
			if($n==2){
				push @nArray,$line;
			}else{				
			}
		}
	}	
	@nArray;
}

#读取配置文件的参数值
sub readSetup{
	my ($setup)=@_;
	
	my ($annot_flag,$main_flag,@array,@paras);
	$annot_flag='#';
	$main_flag="=";
	
	$/="\n";
	open(IN, "$setup") or die("Can't open setup_file $setup, please check!\n");;
	@array=<IN>;
	close IN;
	
	foreach my $line(@array){
		$line=~s/\n//g;
		$line=~s/\s+//g;
		if($line ne "" and $line=~/[a-zA-Z0-9_]{3,}\=/){
			push @paras,$line;
		}		
	}
	@paras;	
}

#读取数组，并过滤掉空元素
sub cleanArray{
	my @array=@_;
	my @narray;
	foreach my $line(@array){
		$line=~s/^\s+//g;
		$line=~s/\s+$//g;
		$line=~s/\n//g;
		$line=~s/\+/ /g;
		$line=~s/\s+/\t/g;
		if($line ne ""){
			push @narray,$line;
		}		
	}
	@narray;	
}

#获取每个表单的变量值
sub getParaValue{
	my ($para_name)=@_;
	
	my ($para_value);	
	foreach my $line(@paras){
		$line=~s/\s+//g;
		$line=~s/\n//g;
		if($line=~/^$para_name\=([0-9a-zA-Z.-_]{1,})/){
			$para_value=$1;
			last;
		}		
	}	
	$para_value;
}