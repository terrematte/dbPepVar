/////// GLOBALS
var ProtExplorer = null;
var PepExplorer = null;

var box_width = 500; // screen.width - 100; //1024;
var box_height = 235;
var char_size = 0; //--global but starts later
var max_chars = 0; //chars fitted within screen

var seq_group = {};
var mspeps = [];
var current_peps = {};
var current_samps = {};
var SeqsList = [];
var alignGrid = [[], []];
var CurrAlignPos = 0;
var MaxGeneSize = 0;
var CurrAlignPos_indicator = null;

var holder_width = 0;
var FocusRef = {};

var highpep_toclean = {};
var highpep_toclean_over = {};
var ActivePep = '';
var ActivePep_over = '';
var ActiveGene = '';

var Alignvert_pos = 0;
var maxaligns_vert = 16;
var GLOBAL_aligns = [];
var GLOBALaln_size = -1; //GLOBAL_aligns.length - 1;
var GRAPH_DATA = {}; //Spectrum data
var SAMPLESEX = {}; //Expression data
var PEPGENES ={};
var GENEZOOM = 20;

var PEP_cutoff = 0;
var selected_Sample = '';

var VertDown_button = null
var VertUp_button = null;
var slider = null;

//seq hover
//var clicked_sequence = null;
var mouseover_sequence = null;

function Draw_grid_A() {
  //#### Draw canvas background
  var bck_path = [];
  for (var grad = 0; grad <= box_width; grad += 20) {
    bck_path.push(["M", grad, 0]);
    bck_path.push(["V", box_height]);
  }

  //vert lines
  var c = ProtExplorer.path(bck_path).attr({
    "stroke-width": 1,
      stroke: "#E6E6E6"
  });


  //vpos msg
  var vpos_maxshow = (Alignvert_pos + maxaligns_vert);
  if (vpos_maxshow > GLOBALaln_size + 1)
    vpos_maxshow = GLOBALaln_size + 1;

  var vpos_initshow = (Alignvert_pos + 1);
  if ( vpos_maxshow <= 0 )
    vpos_initshow = 0;

  var vpos_text = 'View ' + vpos_initshow + ' - ' +  vpos_maxshow + ' of ' + (GLOBALaln_size + 1);
  var vpos_msg = ProtExplorer.text(box_width - 190, 220, vpos_text).attr({
    "text-anchor":"end"
  });


  /////////////////////////// Gene pos bar
  box_width
  ProtExplorer.rect(box_width - 110, 220, 100, 1).attr({
    'fill' : 'black'
  });

  CurrAlignPos_indicator = ProtExplorer.rect(box_width - 111, 215, 3, 10).attr({
    'fill' : 'red'
  });


  ///////////////////////////vert scroll buttons
  VertDown_button = ProtExplorer.path("M8.037,11.166L14.5,22.359c0.825,1.43,2.175,1.43,3,0l6.463-11.194c0.826-1.429,0.15-2.598-1.5-2.598H9.537C7.886,8.568,7.211,9.737,8.037,11.166z").attr({
    'transform': ['t', box_width - 180, 205],
    'fill' : '#d0e2f2',
    'stroke': 'none'
  }).click(
    function() {
      var Alignvert_old = Alignvert_pos;
      Alignvert_pos += 4;

      if (Alignvert_pos + maxaligns_vert - 1 - 4 >= GLOBALaln_size) {
        Alignvert_pos = Alignvert_old;
      } else {
        //$('#spinner').show();
        setTimeout(function() { reset_protbrowser(); }, 200);
        setTimeout(function() { $('#spinner').hide(); }, 500);
      }
  });


  //up
  //ProtExplorer.circle(box_width - 140, 220, 10).attr({
  VertUp_button = ProtExplorer.path("M23.963,20.834L17.5,9.64c-0.825-1.429-2.175-1.429-3,0L8.037,20.834c-0.825,1.429-0.15,2.598,1.5,2.598h12.926C24.113,23.432,24.788,22.263,23.963,20.834z").attr({
    'transform': ['t', box_width - 155, 205],
    'fill' : '#d0e2f2',
    'stroke': 'none'
  }).click(
    function() {
      Alignvert_pos -= 4;
      if (Alignvert_pos < 0) {
        Alignvert_pos = 0;
      } else {
        //$('#spinner').show();
        setTimeout(function() { reset_protbrowser(); }, 200);
        setTimeout(function() { $('#spinner').hide(); }, 500);
      }
  });

}



function Draw_seqs() {
  SeqsList = [];
  mspeps = [];

  var rel_y = 10;
  var order_y = 0;
  var rel_x = (box_width / 2); //start drawing on focus

  //alignments
  ProtExplorer.setStart();

  //vert scroll
  var max_listseq_idx = Alignvert_pos + maxaligns_vert - 1;
  if ( max_listseq_idx > GLOBALaln_size ) {
    max_listseq_idx = GLOBALaln_size;
  }

  if (GLOBALaln_size < 0) {
    $('#logotype').show();
  } else {
    $('#logotype').hide();
  }

  for (var list_sequences_idx = Alignvert_pos; list_sequences_idx <= max_listseq_idx; list_sequences_idx++) {
  //for (var list_sequences_idx in GLOBAL_aligns) {
    var sequence_obj = GLOBAL_aligns[list_sequences_idx];
    if ( sequence_obj.realname == 'merged' ) continue;

    SeqsList.push(sequence_obj.seqname);

    //read seq info from string
    //P240-411-265:390!KXHTEPQXSAAXEYVR
    var regex_match = /([EIPK])(\d+)-(\d+)(-(\S+))?/g;
    var match = regex_match.exec(sequence_obj.structure);

    //interpreter seq data -- and draw
    while (match != null) {
      var seq_struct = match[1];
      var seq_start = parseInt(match[2]);
      var seq_end = parseInt(match[3]);
      var add_inf = match[5];

      //what is the gene max size
      if (! MaxGeneSize ) {
        MaxGeneSize = seq_end;
      } else {
        if ( seq_end > MaxGeneSize ) {
          MaxGeneSize = seq_end;
        }
      }

      //draw structs
      Draw_structs(seq_struct, seq_start, seq_end, add_inf, rel_x, rel_y, order_y, sequence_obj);

      match = regex_match.exec(sequence_obj.structure);
    }

    rel_y += 12; //increase vert position
    order_y ++;
  }

  seq_group = ProtExplorer.setFinish();
}


//Draw seqs part
function Draw_structs(seq_struct, seq_start, seq_end, add_inf, rel_x, rel_y, order_y, sequence_obj) {

  var realname = sequence_obj.realname;

  switch (seq_struct) {
    case ("P"): //Shared peptide
      var y1 = rel_y;
      var color = "#B9C558";// #FFFF33";
      var stroke = "#996633";
      var info_details = add_inf.split('!');
      var pep = info_details[1];

      //hard filter by PEP
      /*var pepref = GRAPH_DATA[pep];
      if ( pepref != undefined ) {
        var pepPEP = parseFloat(pepref[pepref.length - 1][2]);

        if (pepPEP > PEP_cutoff) {
          break;
        }
      }*/

      //hard filter by Sample
      /*if ( selected_Sample ) {
        var samples_list = SAMPLESEX[pep];
        var sampfound = 0;

        for ( var sample_idxaux in samples_list ) {
          var sample = samples_list[sample_idx][0];
          if (selected_Sample == sample) {
            sampfound ++;
          }
        }

        if (! sampfound ) break;
      }*/

      //
      var middle_intron = info_details[0].split(':');
      var middle_start = parseInt(middle_intron[0]);
      var middle_end = parseInt(middle_intron[1]);
      var introned_peps = [];

      if (info_details[0] != 'XXX') {
        introned_peps = [[seq_start, middle_start - 1], [middle_end + 1, seq_end]];

        var y1aux = rel_y + 5;
        ProtExplorer.path([["M", rel_x + middle_start, y1aux], ["H", rel_x + middle_end]]).attr({
          "stroke-width": 2,
          stroke: 'orange',
          'stroke-opacity': 0.5
        });
      } else {
        introned_peps = [[seq_start, seq_end]];
      }

      for (var peppart in introned_peps) {
        //register info
        mspeps.push({
          pep: pep,
          pos_ini: seq_start,
          pos_end: seq_end,
          ref_draw: null,
          clicked: 0,
          order: order_y
        });

        var pep_start = 0 + introned_peps[peppart][0];
        var pep_end = 3 + introned_peps[peppart][1];
        var pep_width = pep_end - pep_start;

        var struct_ref = ProtExplorer.rect(rel_x + pep_start, y1 + 1, pep_width, 6).attr({
          "stroke-width": 0,
          old_stroke: stroke,
          stroke: stroke,
          old_fill: color,
          fill: color,
          title: realname
        }).data(
          'old_stroke', stroke
        ).data(
          'old_fill', color
        );

        //get reference for future
        mspeps[mspeps.length - 1].ref_draw = struct_ref;
        //order_y++;
      }

      break;

    case ("E"): //Exon
      var y1 = rel_y;
      var seq_width = 1 + seq_end - seq_start;

      //default colors --- for Splooce & Human body map ?!?!?
      var color = "#5C5E32";
      var stroke = "#333333";

      var struct_ref = ProtExplorer.rect(rel_x + seq_start, y1, seq_width, 8).attr({
        "stroke-width": 1,
        old_stroke: stroke,
        stroke: stroke,
        old_fill: color,
        fill: color,
        title: realname
      }).data(
        'old_stroke', stroke
        ).data(
          'old_fill', color
          );

      break;

    case ("I"): //Intron
      var y1 = rel_y + 5;
      var linecolor = "#000";
      if (seq_start == 0) linecolor = "#CCCCCC";

      ProtExplorer.path([["M", rel_x + seq_start, y1], ["H", rel_x + seq_end]]).attr({
        "stroke-width": 1,
        stroke: linecolor,
        'stroke-dasharray': "-",
        title: realname
      });
      break;
  }


  /////// Colorize Vert UP and DOWN buttons
  if ( Alignvert_pos <= 0 )
    VertUp_button.attr({ 'fill': '#d0e2f2' });
  else
    VertUp_button.attr({ 'fill': '#337ab7' });


  if ( Alignvert_pos + maxaligns_vert - 1 >= GLOBALaln_size )
    VertDown_button.attr({ 'fill': '#d0e2f2' });
  else
    VertDown_button.attr({ 'fill': '#337ab7' });

}





function loadGenePart ( selected_gene, partNumber, callback ) {
  $.ajax({
    url: "./INPUT/RESULTS/" + selected_gene + "/PROTB_" + selected_gene + ".tmp." + partNumber + ".lzma",
    type: "GET",
    dataType: 'binary',
    processData: false,
    responseType:'arraybuffer',
    async: true,
    cache: false
  })
  .done( function( data ) {
    LZMA.decompress( new Uint8Array( data ), function(result) {
      eval( result );
      console.log( "loaded " + partNumber + " " + selected_gene);
      
      $( "#stats_geneload" ).html( "Loading " + selected_gene + " part." + partNumber);
      callback();
    })
  })
  .fail( function() {
    $( "#stats_geneload" ).html( "Error loading " + partNumber + " : " + selected_gene);
    console.log( "Error loading " + partNumber + " : " + selected_gene);
  });  
}


function loadGene ( selected_gene ) {
  ActiveGene = selected_gene;

  loadGenePart( selected_gene, 1, function () { 
    loadGenePart( selected_gene, 4, function () { 
      loadGenePart( selected_gene, 5, function () { 
        $("#filterpep").val('100');
        PEP_cutoff = $("#filterpep").val();
        fullreset_protbrowser();

        updateSampleList();

        //$('#spinner').hide();
        $( "#stats_geneload" ).html( selected_gene + " successfully loaded" );
        $( "#stats_viewer" ).html( "Viewer: "+ selected_gene );
        $( "#searchgene" ).val( selected_gene );
      });
    });
  });  
}



///// create list of all samples
function updateSampleList () {
  $('#samplist').empty();
  var pepkeys = Object.keys( SAMPLESEX );

  var mouse_events = "onmouseover='Mouseover_samp()' onmouseout='Mouseout_samp()' onClick='selected_Sample=\"\";Click_samp()';";
  $('#samplist').html("<option id='samppid-" + sampname + "' title='" + sampname + "' class='peps' " + mouse_events + " style='color:red;font-size:12px;'>### ALL SAMPLES ###</option>\n");

  var nonred_Samples = {};
  for (var pep_idx in pepkeys) {
    for (var samp_idx in SAMPLESEX[ pepkeys[pep_idx] ]) {
      var sampname = SAMPLESEX[ pepkeys[pep_idx] ][ samp_idx ][ 0 ];
      nonred_Samples[ sampname ] = 0;
    }
  }

  var sampkeys = Object.keys( nonred_Samples );
  for (var pep_idx in sampkeys) {
    var sampname = sampkeys[ pep_idx ];
    var mouse_events = "onmouseover='Mouseover_samp()' onmouseout='Mouseout_samp()' onClick='selected_Sample=\"" + sampname + "\";Click_samp();'";
    $('#samplist').html($('#samplist').html() + "<option id='samppid-" + sampname + "' title='" + sampname + "' class='peps' " + mouse_events + " style='font-size:12px;'>" + sampname + "</option>\n");
  }

  
  /*if ( selected_Sample != null ) {
    $('#samplist').val( selected_Sample );
  }*/

}




///////////////////////
function Draw_gene() {
  var rel_y = 10;
  var order_y = 0;
  var zoom = GENEZOOM;

  var canvas = document.getElementById("genestruct");
  var canvas_ctx = canvas.getContext("2d");

  //clear canvas
  canvas_ctx.clearRect(0, 0, box_width, box_height);
  var canvaswidth = canvas.width;
  canvas.width = 1; canvas.width = box_width;
  canvas.height = 1; canvas.height = box_height;

  //read aligns
  var max_listseq_idx = Alignvert_pos + maxaligns_vert - 1;
  if ( max_listseq_idx > GLOBALaln_size ) {
    max_listseq_idx = GLOBALaln_size;
  }

  var exon_rescale = 1 / zoom;
  var intron_rescale = exon_rescale;

  var CurrAlignPos_aux = 0;
  var toDraw = [];

  for (var list_sequences_idx = Alignvert_pos; list_sequences_idx <= GLOBALaln_size; list_sequences_idx++) {
    var sequence_obj = GLOBAL_aligns[list_sequences_idx];

    if (list_sequences_idx > max_listseq_idx) {
      if (sequence_obj.realname != 'merged') {
        continue;
      }
    }

    //read seq info from string
    var regex_match = /([EKI])(\d+)-(\d+)(-(\S+))?/g;
    var match = regex_match.exec(sequence_obj.structure);

    var posAAsum = 0;
    var posAAold = 0;
    var posGNsum = 0;
    var posGNold = 0;

    while (match != null) {
      var seq_struct = match[1];
      var seq_start = parseInt(match[2]);
      var seq_end = parseInt(match[3]);
      var add_inf = parseInt(match[5]);

      var width = 1 + seq_end - seq_start;
      if ( add_inf ) width = add_inf;

      if (seq_struct != 'K') {
        posAAold = posAAsum;
        posAAsum = posAAsum + width;
      }

      if (seq_struct != 'I') {
        posGNold = posGNsum;
        posGNsum = posGNsum + width;

        if ( sequence_obj.realname != 'merged' ) {
          toDraw.push( [ seq_struct, width, rel_y ] );
        }
      }

      //ONLY WORKS FOR MERGED!!! defines geneposition
      if ( ! CurrAlignPos_aux &&  CurrAlignPos >= 0 && sequence_obj.realname == 'merged') {
        var exonpos_aux = CurrAlignPos - posAAold;

        if (CurrAlignPos + 1 > posAAold && CurrAlignPos + 1 <= posAAsum) {
          CurrAlignPos_aux = (exonpos_aux + posGNold) * exon_rescale - (box_width / 2);
        }

      } else if ( CurrAlignPos < 0 ) {
        CurrAlignPos_aux = CurrAlignPos * exon_rescale - (box_width / 2);

      } else if ( CurrAlignPos > MaxGeneSize ) {
        var exonpos_aux = CurrAlignPos - posAAsum;
        CurrAlignPos_aux = (exonpos_aux + posGNsum) * exon_rescale - (box_width / 2);
      }

      //part_count ++;
      match = regex_match.exec( sequence_obj.structure );
    }

    //////////////////////////////////////////
    rel_y += 12; //increase vert position
    order_y ++;
    toDraw.push( [ 'X', 0, 0 ] );
  }

  //redline
  canvas_ctx.fillStyle="#FF0000";
  canvas_ctx.fillRect( (box_width) / 2 - 1, 0, 2, box_height );

  var rel_x = 0;
  for (var seqpos in toDraw) {
    if ( toDraw[seqpos][0] == 'X' ) {
      rel_x = 0;

    } else if ( toDraw[seqpos][0] == 'K' ) {
      canvas_ctx.fillStyle="#5C5E32";
      var width = toDraw[seqpos][1] * intron_rescale;
      if ( rel_x > 0 ) {
        canvas_ctx.fillRect( rel_x - CurrAlignPos_aux, toDraw[seqpos][2] + 5, width, 1);
      }

      rel_x = rel_x + width;

    } else if ( toDraw[seqpos][0] == 'E' ) {
      canvas_ctx.fillStyle="#5C5E32";
      var width = toDraw[seqpos][1] * exon_rescale;
      canvas_ctx.fillRect( rel_x - CurrAlignPos_aux, toDraw[seqpos][2], width, 10);

      rel_x = rel_x + width;
    }
  }

}


function Draw_focus() {
  //Draw Focus
  var focus_width = max_chars;
  var focus_center = (box_width / 2);
  var posxy = ProtExplorer.text(focus_center - 20, 230, "0 aa");

  //remove focus
  for (var focusitem in FocusRef.items) {
    try {
      FocusRef.items[focusitem].remove();
    }
    catch(err) {
      continue;
    }
  }

  //draw focus
  var focus_add = ProtExplorer.rect(focus_center - 1, 0, 2, box_height).attr({
    stroke: "red",
    fill: "red" ,
    opacity: .90,
      "stroke-width": 0.5
  });

  var focus_bar = ProtExplorer.rect(focus_center - (focus_width / 2), 0, focus_width, box_height).attr({
    stroke: "blue",
    fill: "blue" ,
    opacity: 0.30,
      "stroke-width": 0.50
  });

  //register ref items
  FocusRef.items = new Array();
  FocusRef.items.push(posxy);
  FocusRef.items.push(focus_add);
  FocusRef.items.push(focus_bar);


  //actions
  focus_bar.drag( //during drag
      function(dx, dy) {
        var me = this;
        var desloc_x = me.ox + dx;
        me.attr({x: desloc_x});

        focus_add.attr({x: desloc_x + max_chars / 2 - 1});

        aa_desloc = Math.floor(dx / 3);
        posxy.attr({text: aa_desloc + " aa", x: desloc_x + 30});

      }, //drag start
      function() {
        var me = this;
        var init_posx = me.attr('x');
        me.data("initial_posx", init_posx);
        me.ox = init_posx;
      }, //drag end
      function() {
        var me = this;
        var init_posx = me.data("initial_posx");
        var end_posx = me.attr('x');
        var desloc_x = init_posx - end_posx;

        if ( isNaN(seq_group.ox) ) seq_group.ox = 0;
        desloc_x = desloc_x + seq_group.ox;

        seq_group.transform('t' + desloc_x + ',0');

        me.attr({x: me.data('initial_posx')});
        focus_add.attr({x: me.data('initial_posx') + max_chars / 2 - 1});
        posxy.attr({x: me.data('initial_posx') + 30});

        posxy.attr({text: "0 aa"});

        seq_group.ox = desloc_x;
        desloc_x *= -1;

        CurrAlignPos = desloc_x;
        Draw_aligns(CurrAlignPos);
        Draw_gene();
        Find_peps(CurrAlignPos - max_chars / 2, CurrAlignPos + max_chars / 2);

        ActivePep = '';
        ActivePep_over = '';

        //update pos indicator
        Update_posIndicator();

        //empty search seq box
        $("#searchseq").val('');
        $( "#stats_seqfind" ).html( '' );
      }
  );


  //set init align pos
  if (CurrAlignPos) {
    var desloc_x = CurrAlignPos * -1;

    var me = focus_bar;
    var init_posx = me.data("initial_posx");
    var end_posx = me.attr('x');

    if ( isNaN(seq_group.ox) )
      seq_group.ox = 0;
    seq_group.transform('t' + desloc_x + ',0');

    seq_group.ox = desloc_x;
    desloc_x *= -1;

    CurrAlignPos = desloc_x;
    Draw_aligns(desloc_x);
    Draw_gene();
    Find_peps(desloc_x - max_chars / 2, desloc_x + max_chars / 2);
 }


  //mouse cursor
  focus_bar.mouseover( function () {
    this.attr({'cursor': "grab"});
  }).mouseout( function () {
    this.attr({'cursor': "pointer"});
  });


  Update_posIndicator();
}


////////////////////////
function Update_posIndicator() {
  //update pos indicator
  if ( MaxGeneSize ) {
    if ( CurrAlignPos > MaxGeneSize) CurrAlignPos = MaxGeneSize;
    if ( CurrAlignPos < 0) CurrAlignPos = 0;

    CurrAlignPos_indicator.attr({
      x: box_width - 111 + 100 * (CurrAlignPos / MaxGeneSize)
    });
  }
}



///////////////////////
function Find_peps(focus_start, focus_end) {
  current_peps = {};

  //adjust....
  focus_start -= 2;
  focus_end -= 1;

  //rPrint peplist for focused region
  for (var peptide_idx in mspeps) {
    var peptide = mspeps[peptide_idx];
    var pepref = peptide.ref_draw;

    if (peptide.pos_ini < focus_end && peptide.pos_end > focus_start) {
      if (! current_peps.hasOwnProperty(peptide.pep)) {
        current_peps[peptide.pep] = [];
      }

      current_peps[peptide.pep].push(peptide);
      peptide.clicked = 0;

    } else {
      pepref.attr({
        fill: pepref.data('old_fill'),
        stroke: pepref.data('old_stroke')
      });
    }
  }

  $('#peplist').empty();

  //sort peps
  current_samps = {};

  var current_peps_tosort = Object.keys(current_peps);
  current_peps_tosort.sort();

  for (var peptideseq_pos in current_peps_tosort) {
    var peptideseq = current_peps_tosort[peptideseq_pos];

    if (! (peptideseq in GRAPH_DATA) ) {
      loadGenePart( ActiveGene, "2_" + peptideseq, function () {
        Click_samp();
      });
    }
    
    if (! (peptideseq in SAMPLESEX) ) {
      loadGenePart( ActiveGene, "3_" + peptideseq, function () {
        var samples_list = SAMPLESEX[ peptideseq ];

        for (var sample_idx in samples_list) {
          var sample = samples_list[sample_idx][0];
          if (! sample) continue;

          if ( ! (sample in current_samps) ) current_samps[sample] = {};
          if ( ! (peptideseq in current_samps[sample]) ) current_samps[sample][peptideseq] = [];

          current_samps[sample][peptideseq].push( pepref );
        }
        
        updateSampleList();
      });
    }

    var mouse_events = "onmouseover='Mouseover_pep(\"" + peptideseq + "\")' onmouseout='Mouseout_pep(\"" + peptideseq + "\")' onClick='Click_pep(\"" + peptideseq + "\")'";
    $('#peplist').html($('#peplist').html() + "<option id='pepid-" + peptideseq + "' title='" + peptideseq + "' class='peps' " + mouse_events + " style='font-size:12px;'>" + peptideseq + "</option>\n");

    for (var pepitem_pos in current_peps[peptideseq]) {
      var peptide = current_peps[peptideseq][pepitem_pos];
      var pepref = peptide.ref_draw;
      var order_y = peptide.order;

      /*if ( samples_list ) {
        for (var sample_idx in samples_list) {
          var sample = samples_list[sample_idx][0];
          if (! sample) continue;

          if ( ! (sample in current_samps) ) current_samps[sample] = {};
          if ( ! (peptideseq in current_samps[sample]) ) current_samps[sample][peptideseq] = [];

          current_samps[sample][peptideseq].push( pepref );
        }
      }*/

      //color peps
      pepref.attr({
        fill: "orange"
      }).toFront();

      CorrectFocus();
      
      //draw orange in alignment seq
      var half_hold = Math.floor(max_chars / 2);
      var pep_ini = (0 + peptide.pos_ini + half_hold - CurrAlignPos);
      var pep_end = (3 + peptide.pos_end + half_hold - CurrAlignPos);

      if (pep_ini < 0) pep_ini = 0;
      if (pep_end > max_chars) pep_end = max_chars;

      if (pep_end > 0) {
        for (var charpos = pep_ini; charpos < pep_end; charpos++) {
          var idname = "#id" + order_y + "-" + charpos;
          $( idname ).attr('class','aa aa_focused');
        }
      }

    }
  }

  //inactive pep buttons - wait user to click on one
  $( "#butt_pepspec" ).removeClass("active");
  $( "#butt_pepexpr" ).removeClass("active");
  $( "#butt_pepspec" ).addClass("disabled");
  $( "#butt_pepexpr" ).addClass("disabled");

  //Status of peplist
  $( "#stats_peplist" ).html( "Total of " + Object.keys(current_peps).length + " peptides" );


  //print red those found within other genes
  for ( peptideseq in current_peps ) {
    if ( PEPGENES[ peptideseq ] ) {
      $("option[id='pepid-" + peptideseq + "']").css({color: 'red'});
    }
  }

  //filter peps by PEPs!!!
  Click_samp();
}


function Cleanclick_pep(pepseq) {
  //find pep info
  for (var pepitem in current_peps[pepseq]) {
    var peptide = current_peps[pepseq][pepitem];
    var pepref = peptide.ref_draw;
    peptide.clicked = 0;

    pepref.attr({
      fill: "orange"
    });

    //clean align pep highlight
    for (var pepid in highpep_toclean) {
      $( pepid ).attr('class', 'aa aa_focused');
    }
  }

}


function Cleanclick_pep_over(pepseq) {
  if (ActivePep_over == ActivePep) {
    ActivePep_over = '';
    return;
  }

  //find pep info
  for (var pepitem in current_peps[pepseq]) {
    var peptide = current_peps[pepseq][pepitem];
    var pepref = peptide.ref_draw;

    pepref.attr({ fill: "orange" });
  }

  //clean align pep highlight
  for (var pepid in highpep_toclean_over) {
    var old_class = highpep_toclean_over[ pepid ];
    $( pepid ).attr('class', old_class);
  }

  highpep_toclean_over = {};
  CorrectFocus();
}



function Reload_filter() {
  PEP_cutoff = $("#filterpep").val();

  seq_group = {};
  mspeps = [];
  current_peps = {};
  SeqsList = [];
  alignGrid = [[], []];

  highpep_toclean = {};
  highpep_toclean_over = {};
  ActivePep = '';
  ActivePep_over = '';

  GLOBALaln_size = GLOBAL_aligns.length - 1;

  draw_aligngrid();
  reset_protbrowser();
}


//Clear filters
function Clear_samp() {
  PEP_cutoff = 1;
  selected_Sample = '';

  $('#filterpep').val( PEP_cutoff );
  $("#samplist :selected").prop("selected", false);

  Reload_filter();
}


//////////////////////////////////// show peps from selected sample
function Click_samp() {
  //clean peptide selected
  $('#peplist').val('');
  Cleanclick_pep( ActivePep );
  ActivePep = '';

  //select sample peptides
  /*$('#peplist option')
    .addClass('pepsdisabled');*/

  var peptide_list = Object.keys( current_peps );

  /*if (selected_Sample != '') {
    if (selected_Sample in current_samps) {
      peptide_list = Object.keys( current_samps[ selected_Sample ] );
    } else {
      peptide_list = [];
    }
  }*/

  for (var pep_idx in peptide_list) {
    var pepseq = peptide_list[pep_idx];
    var pepref = GRAPH_DATA[pepseq];
    
    if ( pepref != undefined ) {
      var pepPEP = parseFloat(pepref[pepref.length - 1][2]);

      if (pepPEP <= PEP_cutoff) {
        $('#pepid-' + pepseq)
        .removeClass('pepsdisabled');
      } else {
        $('#pepid-' + pepseq)
        .addClass('pepsdisabled');        
      }
    }
  }

  CorrectFocus();
}


function Mouseover_samp(sample) {
}

function Mouseout_samp() {
}

//////////////////////////////////////

function Mouseover_pep(pepseq) {
  Cleanclick_pep_over(ActivePep_over);
  ActivePep_over = pepseq;

  if (ActivePep_over == ActivePep) {
    ActivePep_over = '';
    return;
  }

  //find pep info
  for (var pepitem in current_peps[pepseq]) {
    var peptide = current_peps[pepseq][pepitem];
    var pepref = peptide.ref_draw;
    var order_y = peptide.order;

    var half_hold = Math.floor(max_chars / 2); //Math.floor
    var pep_ini = (0 + peptide.pos_ini + half_hold - CurrAlignPos);
    var pep_end = (3 + peptide.pos_end + half_hold - CurrAlignPos);

    if (pep_ini < 0) pep_ini = 0;
    if (pep_end > max_chars) pep_end = max_chars;

    if (pep_end > 0) {
      for (var charpos = pep_ini; charpos < pep_end; charpos++) {
        var idname = "#id" + order_y + "-" + charpos;

        if ( ! $( idname ).hasClass('aa_over') )
          highpep_toclean_over[idname] = $( idname ).attr('class');

        $( idname ).attr('class', 'aa aa_over');
      }
    }

    //highlight pep on prot view
    pepref.attr({
      fill: "magenta"
    }).toFront();
  }

  CorrectFocus();
}



function CorrectFocus() {
  //correct Focus arrange
  for (var focusitem in FocusRef.items) {
    FocusRef.items[focusitem].toFront();
  }
}


function Mouseout_pep(pepseq) {
  if (! ActivePep_over)
    return;

  //put clicked top
  for (var pepseqaux in current_peps) {
    for (var pepitem in current_peps[pepseqaux]) {
      var peptide = current_peps[pepseqaux][pepitem];
      var pepref = peptide.ref_draw;

      if ( peptide.clicked ) {
          pepref.attr({ fill: "red" }).toFront();
      }
    }
  }

  //clean
  Cleanclick_pep_over(ActivePep_over);
}


function Click_pep(pepseq) {
  Cleanclick_pep(ActivePep);
  ActivePep = pepseq;
  highpep_toclean = {};

  ActivePep_over = '';
  highpep_toclean_over = {};

  //find pep info
  for (var pepitem in current_peps[pepseq]) {
    var peptide = current_peps[pepseq][pepitem];
    var pepref = peptide.ref_draw;
    var order_y = peptide.order;

    peptide.clicked = 1;

    var half_hold = Math.floor(max_chars / 2); //Math.floor
    var pep_ini = (0 + peptide.pos_ini + half_hold - CurrAlignPos);
    var pep_end = (3 + peptide.pos_end + half_hold - CurrAlignPos);

    if (pep_ini < 0) pep_ini = 0;
    if (pep_end > max_chars) pep_end = max_chars;

    if (pep_end > 0) {
      for (var charpos = pep_ini; charpos < pep_end; charpos++) {
        var idname = "#id" + order_y + "-" + charpos;

        highpep_toclean[idname] = 'aa aa_normal';
        $( idname ).attr('class', 'aa aa_clicked');
      }
    }

    //highlight pep on prot view
    pepref.attr({ fill: "red" }).toFront();
    CorrectFocus();
  }

  //active pep buttons
  $( "#butt_pepspec" ).removeClass("disabled");
  $( "#butt_pepexpr" ).removeClass("disabled");
  $( "#butt_pepspec" ).addClass("active");
  $( "#butt_pepexpr" ).addClass("active");
}


function PepGraph_pre() {
  PepExplorer = Raphael("pepholder", 500, 500);
  PepGraph();
}


/////////////////////////////
function Find_sequence(findseq) {
  findseq = findseq.toUpperCase();
  findseq = findseq.replace(/([A-Z])/g, "($1-*)+?");
  findseq = findseq.replace(/^(.+?)\+\?/, "$1");
  var findseq_re = new RegExp(findseq, "i");

  //vert scroll
  var max_listseq_idx = Alignvert_pos + maxaligns_vert - 1;
  if ( max_listseq_idx > GLOBALaln_size ) {
    max_listseq_idx = GLOBALaln_size;
  }

  for (var seq_idx = Alignvert_pos; seq_idx <= max_listseq_idx; seq_idx++) {
    var align_aux = '';
    align_aux = GLOBAL_aligns[seq_idx].sequence;
    align_aux = align_aux.replace(/=/g, '-');
    align_aux = align_aux.toUpperCase();

    var CurrAlignPos_aux = align_aux.match(findseq_re);
    if (! CurrAlignPos_aux ) continue;
    var match_pos = CurrAlignPos_aux.index; //  * 3;

    if ( match_pos >= 0 ) {
      CurrAlignPos = match_pos;
      Draw_focus();
      return 1;
    }
  }

  return 0;
}


/////////////////////////////
function Get_sequence(line) {
  var align_aux = GLOBAL_aligns[line].sequence;
  align_aux = align_aux.replace(/[=-]+/g, "");
  align_aux = align_aux.replace(/([a-z])\1{2,2}/g, "$1");
  align_aux = align_aux.toUpperCase();

  return align_aux;
}



///////////////////////////
function Draw_aligns(offset) {
  var rel_y = 0;

  //remove popover
  for (var line=0; line < maxaligns_vert; line++) {
    var idline = '#id' + line;
    $(idline).popover('disable');
  }

  //update offset
  offset -= max_chars / 2;

  //vert scroll
  var max_listseq_idx = Alignvert_pos + maxaligns_vert - 1;
  if ( max_listseq_idx > GLOBALaln_size ) {
    var empty_line = max_listseq_idx - GLOBALaln_size;

    //clean lines that are now empty
    if (GLOBALaln_size >= 0) {
      for (var line = maxaligns_vert - 1; line >= maxaligns_vert - empty_line; line--) {
        for (var charpos = 0; charpos < max_chars; charpos++) {
          var idname = "#id" + line + "-" + charpos;
          $( idname ).html('');
        }
      }
    }

    max_listseq_idx = GLOBALaln_size;
  }


  for (var seq_idx = Alignvert_pos; seq_idx <= max_listseq_idx; seq_idx++) {
    var offset_aux = offset;
    var align_aux = '';

    //update seqline name
    var idline = '#id' + rel_y;
    var seqnameaux = GLOBAL_aligns[seq_idx].realname; //seqname;
    if ( seqnameaux == 'merged' ) continue;

    if (GLOBAL_aligns[seq_idx] != null) {
      align_aux = GLOBAL_aligns[seq_idx].sequence;

      var uniprot = /^(tr|sp)\|/;
      var ensembl = /^ENSP\S+?\|/;
      var splooce = /^NM_\d+#\(\S+:\S+\)/;
      var bodymap = /^NM_\d+#(sing|comb)ID\d+/;

      var protclass = '';
      if ( uniprot.test( seqnameaux ) ) protclass = 'Uniprot';
      else if ( ensembl.test( seqnameaux ) ) protclass = 'Ensembl';
      else if ( splooce.test( seqnameaux ) ) protclass = 'Splooce';
      else if ( bodymap.test( seqnameaux ) ) protclass = 'Human Body Map';
      else protclass = 'Unknown';

      $(idline).attr('data-content', "<b>Source: </b>" + protclass + "<br><b>Name: </b>" + seqnameaux);
      $(idline).popover('enable');
    }
    else {
      continue;
    }


    var align_len = align_aux.length;

    if (offset < 0) {
      offset_aux = 0;
      var space;
      for(space = ''; space.length < offset * -1; space += ' '){}
      align_aux = space + GLOBAL_aligns[seq_idx].sequence;
    } else if (offset + max_chars > align_len) {
      var space;
      for(space = ''; space.length < (offset + max_chars) - align_len; space += ' '){}
      align_aux += space;
    }

    //part_seq
    var part_sequence = align_aux.substr(0 + offset_aux, max_chars);
    var part_sequence_aux = part_sequence;
    part_sequence_aux = part_sequence_aux.replace(/\+/g, '-');
    part_sequence_aux = part_sequence_aux.replace(/=/g, ' ');

    //draw align grid items
    var line = rel_y;

    var spaces = 0; //count spaces to get aa pos later
    for (var space_aux = 0; space_aux < offset_aux; space_aux++) {
      if ( align_aux.charAt(space_aux) == '-' ) {
        spaces ++;
      }
    }

    //print aas
    for (var charpos = 0; charpos < max_chars; charpos++) {
      var idname = "#id" + line + "-" + charpos;
      var charseq = part_sequence_aux.substr(charpos, 1);

      //count spaces
      if (charseq == '-')
        spaces++;

      //aa pos
      if (charseq != ' ' && charseq != '-') {
        var aapos = Math.floor( (offset + charpos - spaces) / 3 ) + 1 ;
        $( idname ).attr('data-content', 'pos: ' +  aapos.toString());
        $( idname ).popover('enable');
      }
      else {
        $( idname ).attr('data-content', '');
        $( idname ).popover('disable');
      }

      $( idname ).attr('class', 'aa aa_normal');
      $( idname ).html( charseq );
    }

    rel_y++;
  }

}


//start everything
window.onload = function () {
  draw_aligngrid();
  init_protbrowser();
}


function draw_aligngrid() {
  char_size = 9;                                     //width of char
  max_chars = parseInt((box_width / 1) / char_size); //max chars showed

  $("#aligngrid").html(''); //clean grid

  //central red line
  var central_grid = Math.floor(box_width / 2);
  $("#aligngrid").append("<span style='display:block; position:absolute; left:" + central_grid + "px; width:2px; height:235px; background-color:red;'></span>");


  //html - initialize align grid
  for (var line = 0; line < maxaligns_vert; line ++) {
    var line_aux = 8 + (line * 13);
    var idline = 'id' + line;
    var toappend = "<id id='" + idline + "' tipo='line' class='line_aa_normal' data-toggle='popover' data-placement='left' style='top:" + line_aux + "px' onclick=\"lineClick();\">\n";

    //set char instances
    for (var charpos = 0; charpos < max_chars; charpos++) {
      var charpos_aux = charpos * 9;
      var idname = "id" + line + "-" + charpos;
      toappend += "\t<id class='aa aa_normal' id='" + idname + "' data-toggle='popover' data-placement='top' style='left:" + charpos_aux + "px'> </id>\n";
    }

    toappend += "</id>\n";
    //append
    $("#aligngrid").append(toappend);


    //bootstrap tooltip
    for (var charpos = 0; charpos < max_chars; charpos++) {
      var idname = "id" + line + "-" + charpos;
      $('#' + idname).popover({
        trigger: 'hover'
      });
    }

    //bootstrap popover
    $('#' + idline).popover({
      trigger: 'manual',
      html: true
    });


    //line mouse over
    $('#' + idline).on('mouseenter',
        function() {
          //popover
          $(this).popover('show');
          $('[tipo="line"]').not(this).popover('hide');

          // Mouseover state
          $('.line_aa_normal').removeClass("line_aa_normal_hover");
          mouseover_sequence = $(this).attr('id').replace(/^id/, '');

          if (mouseover_sequence <= (Alignvert_pos - GLOBALaln_size) * -1) {
            $(this).addClass("line_aa_normal_hover");
          } else {
            mouseover_sequence = null;
          }
        })
    .on('mouseleave',
        function() {
          //popover
          $(this).popover('hide');

          // Mouseout state
          if (mouseover_sequence == null) {
            $(this).removeClass("line_aa_normal_hover");
          }

          mouseover_sequence == null;
        });

    }

  }



  //submit to PFAM
  function PFAM_post(option) {

    switch(option) {
      case 'PFAM':
        if (mouseover_sequence) {
          $("#PFAM_seq").val(Get_sequence(mouseover_sequence));
          $("#PFAM_seqForm").submit();
        }
        break;

      case 'UNIPROT':
        if (mouseover_sequence) {
          $("#UNIPROT_seq").val(Get_sequence(mouseover_sequence));
          $("#UNIPROT_seqForm").submit();
        }
        break;

      case 'INTERPRO':
        if (mouseover_sequence) {
          $("#INTERPRO_seq").val(Get_sequence(mouseover_sequence));
          $("#INTERPRO_seqForm").submit();
        }
        break;

    }
  }


  function init_protbrowser() {
    //Initialize Grid
    ProtExplorer = Raphael("holder", box_width, box_height);

    $( '#holder' ).css({
      width: box_width,
      heigth: 235
    });

    $( '#aligngrid' ).css({
      width: box_width,
      heigth: 235
    });

    Draw_grid_A();                  //Draw Grid A - prots
    Draw_seqs();
    Draw_focus();        //Draw focus
    Draw_aligns(CurrAlignPos);      //show aligns
    Draw_gene();
    Find_peps(CurrAlignPos - max_chars / 2, CurrAlignPos + max_chars / 2);          //Find MSMS peps

    PEP_cutoff = $("#filterpep").val();
    $( "#searchgene" ).val( '' );
  }



  function reset_protbrowser() {
    if (ProtExplorer) {
      ProtExplorer.remove();
      init_protbrowser();
    }
  }


  function fullreset_protbrowser() {
    seq_group = {};
    mspeps = [];
    current_peps = {};
    SeqsList = [];
    alignGrid = [[], []];
    CurrAlignPos = 0;
    MaxGeneSize = 0;

    highpep_toclean = {};
    highpep_toclean_over = {};
    ActivePep = '';
    ActivePep_over = '';
    selected_Sample = '';

    Alignvert_pos = 0;
    GLOBALaln_size = GLOBAL_aligns.length - 1;

    draw_aligngrid();
    reset_protbrowser();
  }


  //resize to fit dialog
  function protbrowser_resize() {
    box_width = $( '#dialog-protbrowser' ).width(); // - 240;
    draw_aligngrid();
    reset_protbrowser();

    if ( ActivePep ) {
      Cleanclick_pep( ActivePep );
      ActivePep = '';
    }
  }



  //////////////////////////////////////////////////////////////////////////////////////////////// PEPGRAPH

  function PepGraph(rescale_x_min, rescale_x_max) {
    //clear paper
    PepExplorer.clear();

    //background
    PepExplorer.rect(0, 0, 500, 500).attr({
      stroke: 'none',
      fill: 'white'
    });

    //get peaks
    var PEAKS = GRAPH_DATA[ActivePep];

    //get max axis to later scale
    var max_mass = 0;
    var max_inte = 0;
    var min_mass = 0;
    var min_inte = 0;

    var score_global = 0;
    var score_pep = 0;

    //set slider || rescale
    if ( rescale_x_min && rescale_x_max ) {
      min_mass = rescale_x_min;
      max_mass = rescale_x_max;
    }
    else {
      for (var pos in PEAKS) {
        var ion = PEAKS[pos][0];
        if (ion == 'scores') {
          score_global = PEAKS[pos][1];
          score_pep = PEAKS[pos][2];

          $('#spec_score').html('(Score: ' + score_global + ', PEP: ' + score_pep + ')')
          continue;
        }

        var mass = parseFloat(PEAKS[pos][1]);
        var inten = parseFloat(PEAKS[pos][2]);

        //get max min values for scale graph
        if (! max_mass){
          max_mass = mass;
          min_mass = mass;
        } else if (mass > max_mass) {
          max_mass = mass;
        } else if (mass < min_mass) {
          min_mass = mass;
        }
      }

      min_mass = Math.floor(min_mass - 20);
      max_mass = Math.floor(max_mass + 20);

      slider.slider({
        'min': min_mass,
        'max': max_mass,
        'value': [ min_mass, max_mass ]
      });
      slider.slider('refresh');

    }

    //get min max inten
    for (pos in PEAKS) {
      var ion = PEAKS[pos][0];
      if (ion == 'scores') continue;

      var mass = parseFloat(PEAKS[pos][1]);
      var inten = parseFloat(PEAKS[pos][2]);

      if (mass >= min_mass && mass <= max_mass) {
        if (! max_inte) {
          max_inte = inten;
          min_inte = inten;
        } else if (inten > max_inte) {
          max_inte = inten;
        } else if (inten < min_inte) {
          min_inte = inten;
        }
      }
    }


    //draw scale x
    PepExplorer.path([['M', 20, 452], ['H', 480]]).attr({ fill: 'black', stroke: 'black' });
    var tick_space = (max_mass - min_mass) / 4;
    for (var tickpos = 0; tickpos <= 4; tickpos++) {
      var tick_mass = Math.floor(min_mass + tick_space * tickpos);
      var tick_center = 20 + (tickpos * 115);

      PepExplorer.path([["M", tick_center, 452], ['V', 460]]).attr({ fill: 'black', stroke: 'black' });
      PepExplorer.text(tick_center, 470, tick_mass);
    }

    PepExplorer.text(250, 490, 'm/z').attr({
      'font-size': 14
    });


    //draw peaks
    var x_space = max_mass - min_mass;
    var y_space = max_inte; // - min_inte;

    for (pos in PEAKS) {
      var ion = PEAKS[pos][0];
      if (ion == 'scores') continue;

      var real_mass = parseFloat(PEAKS[pos][1]);
      var real_inten = parseFloat(PEAKS[pos][2]);

      var mass = (real_mass - min_mass) * 450 / x_space;
      var inten = (real_inten) * 380 / y_space;
      if (inten > y_space) inten = y_space;

      if (mass < 0 || inten < 0 || mass > 451 || inten > 381) {
        continue;
      }

      var PEAKCOLOR = {y: 'blue', b: 'green', a: 'red', c: 'red', x: 'red', z: 'red'};


      var regex_match = /([a-z])(\d+)(-\S+|\(\S+)?/i;
      var match = regex_match.exec(ion);
      var ion_type = match[1];
      var ion_pos = match[2];
      var ion_mod = match[3] || 0;
      var pcolor = PEAKCOLOR[ion_type];
      if (ion_mod) pcolor = 'red';
      var aachar_y = ActivePep.substr(ion_pos * -1, 1); //GET FROM END *-1
      var aachar_b = ActivePep.substr(ion_pos - 1, 1); //GET FROM END *-1

      var x_pos = parseInt(mass);
      var y_pos = parseInt(inten);

      //filter ion types
      var IONS_allowed = {'y': 1, 'b': 1, 'a': 1, 'c': 1, 'x': 1, 'z': 1, 'mod': 1};
      if (IONS_allowed[ion_type]) {
        if ((IONS_allowed['mod'] && ! ion_mod) || (IONS_allowed['mod'] && ion_mod) || ! ion_mod) {
        } else {
          continue;
        }
      } else {
        continue;
      }

      //draw peaks
      var peak_ref = PepExplorer.path([["M", x_pos + 25, 450], ["V", 450 - y_pos]]).attr({
        fill: pcolor,
        stroke: pcolor,
        title: ion + "\nmass: " + real_mass + "\nintensity: " + real_inten
      });

      if (! ion_mod && (ion_type == 'y' || ion_type == 'b'))
        var peak_text = PepExplorer.text(x_pos + 25, 450 - y_pos - 10, ion);

      //annot pep sequence
      if (! ion_mod) {
        if (ion_type == 'y') {
          var aa_text = PepExplorer.text(x_pos + 25, 10, aachar_y).attr({
            stroke: "#3377FF"
          });

          var peak_ref = PepExplorer.path([["M", x_pos + 25, 17], ["V", 450 - y_pos - 20]]).attr({
            "stroke-dasharray": ".",
            fill: "#3399FF",
            stroke: "#3399FF"
          });
        } else if (ion_type == 'b') {
          var aa_text = PepExplorer.text(x_pos + 25, 25, aachar_b).attr({
            stroke: "#66FF80"
          });

          var peak_ref = PepExplorer.path([["M",x_pos + 25, 32], ["V",  450 - y_pos - 20]]).attr({
            "stroke-dasharray": ".",
            fill: "#66FF66",
            stroke: "#66FF66"
          });
        }
      }

    }

  }


  //Show Expression Graph
  function ExpGraph() {

    var zscore_range = 3;
    var density_smooth = {};
    var density_smooth_aux = {};

    //samples
    var genes_list = [];
    if ( ActivePep in PEPGENES ) {
      genes_list = PEPGENES[ ActivePep ];
    } else {
       genes_list = ( ActiveGene );
    }


    var samples_list = SAMPLESEX[ ActivePep ].sort(function (a, b){ //sort by z-score
      return a[1] - b[1];
    });

    var htmlbuff = "<ul class='list-group'><li class='list-group-item row-fluid clearfix'><div class='col-md-8'><b>Sample Name</b></div><div class='col-md-4'><b>Expression</b></div></li>\n";

    var maxcount = {};
    var mincount = {};
    var winsmooth = 5;

    for ( var sample_idx in samples_list) {
      var sample_name = samples_list[ sample_idx ][0];

      var zscore = parseFloat(samples_list[ sample_idx ][1]);
      var zscore_ori = parseInt(zscore * 1000) / 1000;

      /////////////////////desnity smooth
      var auxDensity = samples_list[ sample_idx ][2];
      var density = {};

      //load/parse data
      for ( var dens_idx in auxDensity ) {
        var densData = auxDensity[ dens_idx ].split(':');
        var zCount =  parseInt( densData[ 1 ] );
        var zDens = parseInt( densData[ 0 ] * 10 ) / 10;

        density[ zDens ] = zCount;
      }

      //smooth init array
      for ( var wposaux = -50; wposaux < 50; wposaux ++ ) {
        var wzscore = wposaux / 10;
        var wmean = 0;

        if ( wzscore in density ) {
          wmean = density[ wzscore ];
        }

        if (! ( sample_name in density_smooth_aux )) {
          density_smooth_aux[ sample_name ] = [];
        }

        density_smooth_aux[ sample_name ].push( wmean );
      }

      //refine smooth
      for ( var wposaux in density_smooth_aux[ sample_name ] ) {
        var wmean = 0;
        wposaux = parseInt( wposaux );

        for ( var winspos = wposaux - winsmooth; winspos < wposaux + winsmooth; winspos ++ ) {
          var dens_value = density_smooth_aux[ sample_name ][ winspos ];
          if ( dens_value ) {
            wmean += dens_value / ( 1 + Math.abs( wposaux - winspos ) / winsmooth );
          }
        }

        wmean /= (winsmooth * 2 + 1);

        if ( ! ( sample_idx in maxcount) ) maxcount[ sample_idx ] = 0;
        if ( wmean > maxcount[ sample_idx ] ) maxcount[ sample_idx ] = wmean;

        if ( ! ( sample_idx in mincount) ) {
          if ( wmean ) mincount[ sample_idx ] = wmean;
        }

        if ( wmean < mincount[ sample_idx ] ) {
          if ( wmean ) mincount[ sample_idx ] = wmean;
        }

        if (! ( sample_name in density_smooth )) {
          density_smooth[ sample_name ] = [];
        }

        density_smooth[ sample_name ][ wposaux ] = wmean;
      }

      ////////////////
      if (zscore > zscore_range / 2) {
        zscore = zscore_range / 2;
      } else if (zscore < zscore_range / 2 * - 1) {
        zscore = zscore_range / 2 * - 1;
      }

      zscore = parseInt(zscore * 1000) / 1000;

      var color = parseInt((255 / zscore_range) * (Math.abs(zscore) + zscore_range / 2));
      var colorstr = "rgb(0, " + color + ", 0)";

      if (zscore <= 0) {
        colorstr = "rgb(" + color + ", 0, 0)";
      }

      htmlbuff += "<li class='list-group-item row-fluid clearfix' style='padding-top:0px;padding-bottom:0px;'><div class='col-md-6' style='font-size:12px;'>" +
                  sample_name + "</div><div class='col-md-3' style='text-align:center;color:white;background-color:" +
                  colorstr + ";'><b>" + zscore_ori + "</b></div><div class='col-md-3'>" +
                  "<canvas id='Exp_" + sample_name + "' width='96' height='20'></canvas></div></li>\n";

    }
    htmlbuff += "</ul>\n";
    $( '#expholder_samples' ).html( htmlbuff );
    htmlbuff = "";

    //draw density plot using canvas
    for ( var sample_idx in samples_list ) {
      var sample_name = samples_list[ sample_idx ][0];
      var densArray = density_smooth[ sample_name ];

      var c = document.getElementById("Exp_" + sample_name);
      var ctx = c.getContext("2d");
      //ctx.beginPath();
      //ctx.strokeStyle = '#000000';
      ctx.beginPath();
      ctx.moveTo(0, 10);
      ctx.lineTo(100, 10);

      for ( var wpos in densArray ) {
        var densVal = densArray[ wpos ] - mincount[ sample_idx ];
        densVal /= maxcount[ sample_idx ] - mincount[ sample_idx ];
        densVal *= 10;

        if ( densVal < 0 ) densVal = 0;

        ctx.moveTo((wpos + winsmooth) / 10, 10);
        ctx.lineTo((wpos + winsmooth) / 10, 10 - densVal);

        ctx.moveTo((wpos + winsmooth) / 10, 10);
        ctx.lineTo((wpos + winsmooth) / 10, 10 + densVal);
      }

      ctx.strokeStyle = 'black';
      ctx.stroke();

      var zscore = parseFloat(samples_list[ sample_idx ][1]);
      ctx.beginPath();
      ctx.strokeStyle = '#000000';
      ctx.lineWidth = 3;
      ctx.moveTo(zscore * 10 + 50, 0);
      ctx.lineTo(zscore * 10 + 50, 20);

      ctx.strokeStyle = 'red';
      ctx.stroke();
    }


    //genes
    htmlbuff += "<li class='list-group-item  row-fluid clearfix'><div class='col-md-8'>" + ActiveGene + "</div><div class='col-md-4'>" + GENEPEPS[ ActiveGene ] + "</div></li>\n";
 
    if ( ActivePep in PEPGENES ) {
      var genes_list = PEPGENES[ ActivePep ];
 
      for ( var genes_idx in genes_list) {
        var gene_name = genes_list[ genes_idx ];
        var gene_pepcount = GENEPEPS[ gene_name ];
        htmlbuff += "<li class='list-group-item  row-fluid clearfix'><div class='col-md-8'>" + gene_name + "</div><div class='col-md-4'>" + gene_pepcount + "</div></li>\n";
      }
    }

    htmlbuff += "</ul>\n";
    $( '#expholder_genes' ).html( htmlbuff );

  }
