import 'package:flutter/material.dart';

import 'theme.dart';
import 'package:mediaplex/home/models/show_model.dart';

List<ShowModel> showModels = [
  ShowModel(
    show_type: 'Live',
    data: Icons.connected_tv,
    total_channels: 0,
    child: Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
        child: Text('Live', style: MyTheme.appText(size: 20, isShadow: true, weight: FontWeight.w600))
      ),
      const SizedBox(width: 4),
      Text('TV', style: MyTheme.appText(size: 20, isShadow: true, weight: FontWeight.w600))
    ])
  ),
  ShowModel(
    show_type: 'News',
    data: Icons.newspaper,
    total_channels: 0,
    child: Text('News', style: MyTheme.appText(size: 20, isShadow: true, weight: FontWeight.w600))),
  ShowModel(
    data: Icons.movie,
    show_type: 'Movies',
    total_channels: 0,
    child: Text('Movies', style: MyTheme.appText(size: 20, isShadow: true, weight: FontWeight.w600))),
  ShowModel(
      show_type: 'Music',
      total_channels: 0,
      data: Icons.music_note_outlined,
      child: Text(
        'Music',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      )),
  ShowModel(
      total_channels: 0,
      data: Icons.card_travel_outlined,
      child: Text(
        'Auto',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Auto'),
  ShowModel(
      total_channels: 0,
      data: Icons.business,
      child: Text(
        'Business',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Business'),
  ShowModel(
      total_channels: 0,
      data: Icons.theater_comedy,
      child: Text(
        'Comedy',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Comedy'),
  ShowModel(
      total_channels: 0,
      data: Icons.theaters,
      child: Text(
        'Documentary',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Documentary'),
  ShowModel(
      total_channels: 0,
      data: Icons.cast_for_education,
      child: Text(
        'Education',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Education'),
  ShowModel(
      total_channels: 0,
      data: Icons.movie_filter_sharp,
      child: Text(
        'Entertainment',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Entertainment'),
  ShowModel(
      total_channels: 0,
      data: Icons.family_restroom,
      child: Text(
        'Family',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Family'),
  ShowModel(
      total_channels: 0,
      data: Icons.style,
      child: Text(
        'Fashion',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Fashion'),
  ShowModel(
      total_channels: 0,
      data: Icons.dinner_dining,
      child: Text(
        'Food',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Food'),
  ShowModel(
      total_channels: 0,
      data: Icons.abc,
      child: Text(
        'General',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'General'),
  ShowModel(
      total_channels: 0,
      data: Icons.health_and_safety,
      child: Text(
        'Health',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Health'),
  ShowModel(
      total_channels: 0,
      data: Icons.history_edu,
      child: Text(
        'History',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'History'),
  ShowModel(
      total_channels: 0,
      data: Icons.games,
      child: Text(
        'Hobby',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Hobby'),
  ShowModel(
      total_channels: 0,
      data: Icons.child_friendly,
      child: Text(
        'Kids',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Kids'),
  ShowModel(
      total_channels: 0,
      data: Icons.policy,
      child: Text(
        'Legislative',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Legislative'),
  ShowModel(
      total_channels: 0,
      data: Icons.monitor_heart_rounded,
      child: Text(
        'Lifestyle',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Lifestyle'),
  ShowModel(
      total_channels: 0,
      data: Icons.local_activity,
      child: Text(
        'Local',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Local'),
  ShowModel(
      total_channels: 0,
      data: Icons.temple_buddhist,
      child: Text(
        'Religious',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Religious'),
  ShowModel(
      total_channels: 0,
      data: Icons.shop,
      child: Text(
        'Shops',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Shops'),
  ShowModel(
      total_channels: 0,
      data: Icons.sports,
      child: Text(
        'Sports',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Sports'),
  ShowModel(
      total_channels: 0,
      data: Icons.travel_explore,
      child: Text(
        'Travel',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Travel'),
  ShowModel(
      total_channels: 0,
      data: Icons.sunny,
      child: Text(
        'Weather',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Weather'),
  ShowModel(
      total_channels: 0,
      data: Icons.local_attraction,
      child: Text(
        'Adult',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'XXX'),
  ShowModel(
      total_channels: 0,
      data: Icons.outbond_sharp,
      child: Text(
        'Other',
        style: MyTheme.appText(
            size: 20, weight: FontWeight.w600, isShadow: true),
      ),
      show_type: 'Other'),
];

List<String> countryIcons = [
  'ae',
  'af',
  'al',
  'am',
  'ao',
  'ar',
  'at',
  'au',
  'aw',
  'az',
  'ba',
  'bb',
  'bd',
  'be',
  'bf',
  'bg',
  'bh',
  'bn',
  'bo',
  'br',
  'by',
  'ca',
  'cd',
  'ch',
  'ci',
  'cl',
  'cm',
  'cn',
  'co',
  'cr',
  'cw',
  'cr',
  'cw',
  'cy',
  'cz',
  'de',
  'dk',
  'do',
  'dz',
  'ec',
  'ee',
  'eg',
  'eh',
  'es',
  'et',
  'fi',
  'fj',
  'fo',
  'fr',
  'ge',
  'gh',
  'gm',
  'gq',
  'gr',
  'gy',
  'hk',
  'hn',
  'hr',
  'hu',
  'id',
  'ie',
  'il',
  'in',
  'ir',
  'is',
  'it',
  'jm',
  'jo',
  'jp',
  'ke',
  'kg',
  'kh',
  'kn',
  'kp',
  'kr',
  'kw',
  'kz',
  'la',
  'lb',
  'li',
  'lk',
  'lt',
  'lu',
  'lv',
  'ly',
  'ma',
  'md',
  'me',
  'mm',
  'mn',
  'mo',
  'mx',
  'my',
  'mz',
  'ng',
  'ni',
  'no',
  'np',
  'om',
  'pa',
  'pe',
  'ph',
  'pk',
  'pl',
  'pr',
  'ps',
  'pt',
  'py',
  'qa',
  'ro',
  'ru',
  'rw',
  'ad',
  'sa',
  'sd',
  'se',
  'sg',
  'si',
  'sk',
  'sm',
  'sn',
  'so',
  'sv',
  'sy',
  'th',
  'tj',
  'tm',
  'tn',
  'tr',
  'tt',
  'tz',
  'ua',
  'ug',
  'us',
  'uy',
  've',
  'ye',
  'za'
];
